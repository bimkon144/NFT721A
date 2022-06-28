import { Web3ReactProvider } from '@web3-react/core';
import React from 'react';
import ReactDOM from 'react-dom';
import { App } from './App';
import './index.scss';
import { getProvider } from './utils/provider';
import { MoralisProvider } from "react-moralis";

ReactDOM.render(
  <React.StrictMode>
    <Web3ReactProvider getLibrary={getProvider}>
      <MoralisProvider serverUrl="https://ycdrwalsmowu.usemoralis.com:2053/server" appId="OMmCccFisfG41m6CAL0NUsZIjyn959QUTkPv89Jg">
        <App />
      </MoralisProvider>
    </Web3ReactProvider>
  </React.StrictMode>,
  document.getElementById('root')
);
