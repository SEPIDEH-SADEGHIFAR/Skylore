import { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

// This component updates the map view when location is found
function LocationSetter() {
  const map = useMap();
  
  useEffect(() => {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          map.setView([latitude, longitude], 13);
        },
        (error) => {
          console.error("Error getting location: ", error.message);
        },
        { enableHighAccuracy: true }
      );
    } else {
      console.log("Geolocation is not available in your browser.");
    }
  }, [map]);
  
  return null;
}

// This component shows the user's location marker
function UserLocationMarker() {
  const [position, setPosition] = useState(null);
  
  useEffect(() => {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setPosition([position.coords.latitude, position.coords.longitude]);
        },
        (error) => {
          console.error("Error getting location: ", error.message);
        },
        { enableHighAccuracy: true }
      );
    }
  }, []);
  
  return position ? (
    <Marker position={position}>
      <Popup>You are here</Popup>
    </Marker>
  ) : null;
}

export default function Map() {
  // Default location in case geolocation fails
  const defaultPosition = [51.505, -0.09];
  
  return (
    <div className="map-container">
      <MapContainer 
        center={defaultPosition} 
        zoom={13} 
        style={{ height: '100vh', width: '100%' }}
      >
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        />
        <LocationSetter />
        <UserLocationMarker />
      </MapContainer>
    </div>
  );
} 