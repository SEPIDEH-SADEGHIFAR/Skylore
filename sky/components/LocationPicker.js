import { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMapEvents, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix Leaflet icon issues
// This fixes the missing marker icon problem
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

// This component centers the map on a specific position
function MapCenterer({ position }) {
  const map = useMap();
  
  useEffect(() => {
    if (position) {
      map.flyTo(position, 15);
    }
  }, [position, map]);
  
  return null;
}

// This component handles map click events
function MapClickHandler({ onMapClick }) {
  useMapEvents({
    click: (e) => {
      onMapClick(e);
    },
  });
  return null;
}

export default function LocationPicker({ onLocationSelect }) {
  const [showMap, setShowMap] = useState(false);
  const [userLocation, setUserLocation] = useState(null);
  const [selectedLocation, setSelectedLocation] = useState(null);
  const [error, setError] = useState(null);

  // Request location permission and get user location
  const requestLocationPermission = () => {
    if (!navigator.geolocation) {
      setError("Geolocation is not supported by your browser");
      return;
    }

    setError(null);
    
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        const userPos = [latitude, longitude];
        setUserLocation(userPos);
        setSelectedLocation(userPos); // Initialize selected location to user location
        setShowMap(true); // Only show map after getting location
      },
      (error) => {
        console.error("Error getting location:", error);
        if (error.code === error.PERMISSION_DENIED) {
          setError("Location permission denied. Please allow location access to use this feature.");
        } else {
          setError("Unable to retrieve your location. Please try again.");
        }
      },
      { enableHighAccuracy: true }
    );
  };

  // Handle map click to select location
  const handleMapClick = (e) => {
    setSelectedLocation([e.latlng.lat, e.latlng.lng]);
    if (onLocationSelect) {
      onLocationSelect({
        lat: e.latlng.lat,
        lng: e.latlng.lng
      });
    }
  };

  // Confirm selected location
  const confirmLocation = () => {
    if (selectedLocation && onLocationSelect) {
      onLocationSelect({
        lat: selectedLocation[0],
        lng: selectedLocation[1]
      });
    }
  };

  return (
    <div className="location-picker">
      {!showMap ? (
        <div className="permission-request">
          <button 
            className="location-button"
            onClick={requestLocationPermission}
          >
            Choose Current Location
          </button>
          {error && <p className="error-message">{error}</p>}
        </div>
      ) : (
        <div className="map-container">
          <MapContainer 
            center={userLocation || [0, 0]} 
            zoom={15} 
            style={{ height: '400px', width: '100%' }}
          >
            <TileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            />
            {userLocation && (
              <Marker position={userLocation}>
                <Popup>Your current location</Popup>
              </Marker>
            )}
            {selectedLocation && 
             // Check if selectedLocation is different from userLocation
             (userLocation === null || 
              selectedLocation[0] !== userLocation[0] || 
              selectedLocation[1] !== userLocation[1]) && (
              <Marker position={selectedLocation}>
                <Popup>Selected location</Popup>
              </Marker>
            )}
            <MapCenterer position={userLocation} />
            <MapClickHandler onMapClick={handleMapClick} />
          </MapContainer>
          <div className="map-controls">
            <button onClick={confirmLocation}>Confirm Location</button>
          </div>
        </div>
      )}
    </div>
  );
} 