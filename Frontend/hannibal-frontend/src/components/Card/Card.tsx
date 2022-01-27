import React from 'react';
import styled from 'styled-components';

const Card: React.FC = ({ children }) => <StyledCard>{children}</StyledCard>;

const StyledCard = styled.div`
  background-color: #2b2122; //${(props) => props.theme.color.grey[800]};
  color: #563830 !important;
  display: flex;
  flex: 1;
  flex-direction: column;
`;

export default Card;
