import React from 'react';
import { Modal, Box, Typography } from '@mui/material';

const style = {
  position: 'absolute' as 'absolute',
  top: '50%',
  left: '50%',
  transform: 'translate(-50%, -50%)',
  width: 400,
  bgcolor: 'background.paper',
  border: '2px solid #000',
  boxShadow: 24,
  p: 4,
};

const DetailsModal: React.FC<{ open: boolean; handleClose: () => void }> = ({ open, handleClose }) => {
  return (
    <Modal
      open={open}
      onClose={handleClose}
      aria-labelledby="modal-modal-title"
      aria-describedby="modal-modal-description"
    >
      <Box sx={style}>
        <Typography id="modal-modal-title" variant="h6" component="h2">
          Trade Details
        </Typography>
        <Typography id="modal-modal-description" sx={{ mt: 2 }}>
          Payoff curve, strike table, greeks will go here.
        </Typography>
      </Box>
    </Modal>
  );
};

export default DetailsModal;
