import { useWeb3React } from '@web3-react/core';
import { ReactElement, useEffect, useState } from 'react';
import { Provider } from '../utils/provider';

function ChainId(): ReactElement {
    const { chainId } = useWeb3React<Provider>();
  
    return (
      <>
        <span>
          <strong>Chain Id</strong>
        </span>
        <span role="img" aria-label="chain">
          ⛓
        </span>
        <span>{chainId ?? ''}</span>
      </>
    );
  }

  export default ChainId;