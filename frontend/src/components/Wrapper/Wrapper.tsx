import { useWeb3React } from '@web3-react/core';
import { ReactElement, useEffect, useState } from 'react';

const Wrapper = (props: { children: ReactElement[] }) => {
  const { children } = props;

  return (
    <>
      <div className="main-container-page-with-footer__wrapper">
        <div className="main-container-page-with-footer__content">
          {children[0]}
        </div>
        <div className="main-container-page-with-footer__body">
          {children[1]}
        </div>
        <div className="main-container-page-with-footer__footer">
          {children[2]}
        </div>
      </div>
    </>
  );
};

export default Wrapper;
