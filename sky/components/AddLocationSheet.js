import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, useMap, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

// Fix for Leaflet marker icons
import L from 'leaflet';

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

// Component to center map on user location
function MapController({ userLocation }) {
  const map = useMap();
  
  useEffect(() => {
    if (userLocation) {
      map.flyTo(userLocation, 15);
    }
  }, [userLocation, map]);
  
  return null;
}

// Component to handle map click events
function MapClickHandler({ onLocationSelect }) {
  useMapEvents({
    click: (e) => {
      onLocationSelect([e.latlng.lat, e.latlng.lng]);
    }
  });
  
  return null;
}

function AddLocationSheet({ onSave, onClose }) {
  const [isLoading, setIsLoading] = useState(false);
  const [locationPermissionGranted, setLocationPermissionGranted] = useState(false);
  const [userLocation, setUserLocation] = useState(null);
  const [selectedLocation, setSelectedLocation] = useState(null);
  const [errorMessage, setErrorMessage] = useState('');

  // Request permission when component mounts
  useEffect(() => {
    requestLocationPermission();
  }, []);

  const requestLocationPermission = () => {
    setIsLoading(true);
    setErrorMessage('');
    
    if (!navigator.geolocation) {
      setErrorMessage('Geolocation is not supported by your browser');
      setIsLoading(false);
      return;
    }
    
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        setUserLocation([latitude, longitude]);
        setSelectedLocation([latitude, longitude]); // Set initial selection to user location
        setLocationPermissionGranted(true);
        setIsLoading(false);
      },
      (error) => {
        console.error('Error getting location:', error);
        setErrorMessage(
          error.code === 1 
            ? 'Location permission denied. Please enable location services.'
            : 'Unable to get your location. Please try again.'
        );
        setLocationPermissionGranted(false);
        setIsLoading(false);
      },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
    );
  };

  const handleSelectLocation = (coords) => {
    setSelectedLocation(coords);
  };

  const handleSaveLocation = () => {
    if (selectedLocation) {
      onSave({ 
        latitude: selectedLocation[0], 
        longitude: selectedLocation[1] 
      });
    }
  };

  return (
    <div className="add-location-sheet">
      <div className="sheet-header">
        <h2>Choose Location</h2>
        <button className="close-button" onClick={onClose}>×</button>
      </div>
      
      <div className="sheet-content">
        {isLoading ? (
          <div className="loading-indicator">Loading your location...</div>
        ) : errorMessage ? (
          <div className="error-container">
            <p className="error-message">{errorMessage}</p>
            <button 
              className="retry-button"
              onClick={requestLocationPermission}
            >
              Retry
            </button>
          </div>
        ) : (
          <>
            <div className="map-wrapper">
              {locationPermissionGranted && (
                <MapContainer 
                  center={userLocation || [0, 0]} 
                  zoom={15} 
                  style={{ height: '300px', width: '100%' }}
                >
                  <TileLayer
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                  />
                  
                  {selectedLocation && (
                    <Marker position={selectedLocation} />
                  )}
                  
                  <MapController userLocation={userLocation} />
                  <MapClickHandler onLocationSelect={handleSelectLocation} />
                </MapContainer>
              )}
            </div>
            
            <div className="location-actions">
              <p className="location-hint">
                Tap the map to set your exact location or use your current position
              </p>
              
              <div className="button-group">
                <button 
                  className="cancel-button" 
                  onClick={onClose}
                >
                  Cancel
                </button>
                <button 
                  className="save-button" 
                  onClick={handleSaveLocation}
                  disabled={!selectedLocation}
                >
                  Save Location
                </button>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export default AddLocationSheet; 