import React from 'react';
import TickerInput from './TickerInput';
import StrategySelect from './StrategySelect';
import ScanButton from './ScanButton';

const ScanControls: React.FC = () => {
  return (
    <div>
      <TickerInput />
      <StrategySelect />
      <ScanButton />
    </div>
  );
};

export default ScanControls;
