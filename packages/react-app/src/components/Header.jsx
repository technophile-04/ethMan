import React from "react";
import { Typography } from "antd";

const { Title, Text } = Typography;

// displays a page header

export default function Header({ link, title, subTitle1, subTitle2, ...props }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between", padding: "1.2rem" }}>
      <div style={{ display: "flex", flexDirection: "column", flex: 1, alignItems: "start" }}>
        <a href={link} target="_blank" rel="noopener noreferrer">
          <Title level={4} style={{ margin: "0 0.5rem 0 0" }}>
            {title}
          </Title>
        </a>
        <Text type="secondary" style={{ textAlign: "left" }}>
          {subTitle1}
        </Text>
        <Text type="secondary" style={{ textAlign: "left" }}>
          {subTitle2}
        </Text>
      </div>
      {props.children}
    </div>
  );
}

Header.defaultProps = {
  link: "https://github.com/technophile-04/ethMan",
  title: "🧍‍♂️ ETH Man",
  subTitle1: "ETH Man reacts to live ETH price from oracles !.",
  subTitle2: "He is happy 🙂 when its up 📈 and sad 🙁 when its down 📉 then previous value.",
};
