import React from 'react';
import { FormControl, InputLabel, Select, MenuItem } from '@mui/material';

const StrategySelect: React.FC = () => {
  return (
    <FormControl variant="outlined">
      <InputLabel>Strategy</InputLabel>
      <Select label="Strategy">
        <MenuItem value="">
          <em>None</em>
        </MenuItem>
        <MenuItem value="basic_straddle">Basic Straddle</MenuItem>
      </Select>
    </FormControl>
  );
};

export default StrategySelect;
