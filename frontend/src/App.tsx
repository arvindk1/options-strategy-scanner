import React from 'react';
import Header from './components/Header';
import ScanControls from './components/ScanControls';
import FiltersPanel from './components/FiltersPanel';
import ResultsList from './components/ResultsList';
import DetailsModal from './components/DetailsModal';
import { Container, CssBaseline } from '@mui/material';

const App: React.FC = () => {
  const [open, setOpen] = React.useState(false);
  const handleOpen = () => setOpen(true);
  const handleClose = () => setOpen(false);

  return (
    <React.Fragment>
      <CssBaseline />
      <Container>
        <Header />
        <ScanControls />
        <FiltersPanel />
        <ResultsList />
        <button onClick={handleOpen}>Show Details</button>
        <DetailsModal open={open} handleClose={handleClose} />
      </Container>
    </React.Fragment>
  );
};

export default App;
