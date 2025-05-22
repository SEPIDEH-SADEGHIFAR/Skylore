import { useState } from 'react';
import Map from './Map';

export default function LocationMap() {
  const [showMap, setShowMap] = useState(false);
  
  const handleShowMap = () => {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        () => {
          // Permission granted, show the map
          setShowMap(true);
        },
        (error) => {
          console.error("Error getting location: ", error.message);
          // Show map anyway, it will use the default location
          setShowMap(true);
        }
      );
    } else {
      // Geolocation not available, show map with default location
      setShowMap(true);
    }
  };
  
  return (
    <div>
      {!showMap ? (
        <button 
          onClick={handleShowMap}
          className="location-button"
        >
          Use My Current Location
        </button>
      ) : (
        <Map />
      )}
    </div>
  );
} 