#!/bin/bash

# 1. Install dependencies
npm install chart.js chartjs-node-canvas

# 2. Create the dashboard page
mkdir -p src/pages
cat << 'EOF' > src/pages/dashboard.tsx
import { GetServerSideProps } from 'next';
import { ChartJSNodeCanvas } from 'chartjs-node-canvas';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getServerSideProps: GetServerSideProps = async () => {
  const users = await prisma.user.findMany();
  const chartJSNodeCanvas = new ChartJSNodeCanvas({ width: 400, height: 400 });

  const configuration = {
    type: 'bar',
    data: {
      labels: users.map(user => user.name),
      datasets: [{
        label: '# of Votes',
        data: users.map(() => Math.floor(Math.random() * 100)),
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1
      }]
    }
  };

  const image = await chartJSNodeCanvas.renderToDataURL(configuration);

  return {
    props: {
      chartImage: image,
    },
  };
};

const DashboardPage = ({ chartImage }) => {
  return (
    <div>
      <h1>Analytics Dashboard</h1>
      <img src={chartImage} alt="Chart" />
    </div>
  );
};

export default DashboardPage;
EOF
