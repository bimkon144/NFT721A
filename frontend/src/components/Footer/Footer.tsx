import { FC } from 'react';
import { Link } from 'react-router-dom';

const Footer: FC = () => {
  const navbarRight = [
    { name: '', to: '/' },
    { name: '', to: '/blogs' },
    { name: '', to: '/contact' },
  ];
  const navbarLeft = [
    { name: '', to: '/' },
    { name: '', to: '/blogs' },
    { name: '', to: '/contact' },
  ];
  return (
    <header className="header">
      <nav className="header__navbar">
        <ul className='header__list'>
          {navbarLeft.map((item) => (
            <li key={item.name} className="header__link-container">
              <Link to={item.to} key={item.name} className="header__link-item">
                <div className="header__link">{item.name}</div>
              </Link>
            </li>
          ))}
        </ul>
      </nav>
      <nav className="header__navbar">
        <ul className='header__list'>
          {navbarRight.map((item) => (
            <li key={item.name} className="header__link-container">
              <Link to={item.to} key={item.name} className="header__link-item">
                <div className="header__link">{item.name}</div>
              </Link>
            </li>
          ))}
        </ul>
      </nav>
    </header>
  );
};

export default Footer;
