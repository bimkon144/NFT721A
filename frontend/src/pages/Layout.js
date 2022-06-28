import { Outlet, Link } from "react-router-dom";
import Footer from "../components/Footer/Footer";
import Header from "../components/Header/Header";
import Wrapper from "../components/Wrapper/Wrapper";

const Layout = () => {
  return (
    <>
      <Wrapper>
        <Header />
        <Outlet />
        <Footer />
      </Wrapper>

    </>
  )
};

export default Layout;