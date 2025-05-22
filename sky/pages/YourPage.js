import { useState } from 'react';
import AddLocationSheet from '../components/AddLocationSheet';
import '../styles/AddLocationSheet.css';

function YourPage() {
  const [showLocationSheet, setShowLocationSheet] = useState(false);
  const [location, setLocation] = useState(null);

  const handleOpenLocationSheet = () => {
    setShowLocationSheet(true);
  };

  const handleCloseLocationSheet = () => {
    setShowLocationSheet(false);
  };

  const handleSaveLocation = (location) => {
    setLocation(location);
    setShowLocationSheet(false);
    // Do something with the location (save to state/API/etc)
    console.log('Saved location:', location);
  };

  return (
    <div>
      <h1>Your Page</h1>
      
      <button onClick={handleOpenLocationSheet}>
        Choose Location
      </button>
      
      {location && (
        <div>
          <p>Selected Location: {location.latitude}, {location.longitude}</p>
        </div>
      )}
      
      {showLocationSheet && (
        <div className="sheet-overlay">
          <AddLocationSheet 
            onSave={handleSaveLocation}
            onClose={handleCloseLocationSheet}
          />
        </div>
      )}
    </div>
  );
}

export default YourPage; 