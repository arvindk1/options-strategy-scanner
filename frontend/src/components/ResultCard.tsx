import React from 'react';
import { Card, CardContent, CardActions, Button, Typography } from '@mui/material';

const ResultCard: React.FC = () => {
  return (
    <Card>
      <CardContent>
        <Typography variant="h5" component="h2">
          AAPL - 45 DTE - Basic Straddle
        </Typography>
        <Typography color="textSecondary">
          Credit: $5.00
        </Typography>
        <Typography variant="body2" component="p">
          P/L Range: -$10.00 to $100.00
        </Typography>
      </CardContent>
      <CardActions>
        <Button size="small">View Details</Button>
        <Button size="small">Place Trade</Button>
      </CardActions>
    </Card>
  );
};

export default ResultCard;
