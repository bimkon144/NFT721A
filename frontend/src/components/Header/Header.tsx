import { FC } from 'react';
import { Link } from 'react-router-dom';
import { ActivateDeactivate } from '../ActivateDeactivate/ActivateDeactivate';

const Header: FC = () => {
  const navbar = [
    { name: '', to: '/' },
    { name: '', to: '/blogs' },
    { name: '', to: '/contact' },
  ];
  return (
    <header className="header">
      <div className="header__wrapper">
        <Link to="/" className='header__link-item'>
          <div className="header__main-title">
            <div className="header__title">CryptoFlowV1</div>
            <div className="header__tagline">Just send it!</div>
          </div>
        </Link>
        <ActivateDeactivate />
        <nav className="header__navbar">
          <ul className='header__list'>
            {navbar.map((item) => (
              <li key={item.name} className="header__link-container">
                <Link to={item.to} key={item.name} className="header__link-item">
                  <div className="header__link">{item.name}</div>
                </Link>
              </li>
            ))}
          </ul>
        </nav>
      </div>
    </header>
  );
};

export default Header;
