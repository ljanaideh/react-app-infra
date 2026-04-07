import React, { useEffect, useRef } from 'react';

function App() {
  const canvasRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    let animationId;
    let time = 0;

    const resize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };
    resize();
    window.addEventListener('resize', resize);

    const stars = Array.from({ length: 300 }, () => ({
      x: Math.random(),
      y: Math.random(),
      size: Math.random() * 2 + 0.5,
      twinkle: Math.random() * Math.PI * 2,
      speed: Math.random() * 0.02 + 0.005,
    }));

    const drawGlow = (x, y, radius, color, glowSize) => {
      const gradient = ctx.createRadialGradient(x, y, radius * 0.3, x, y, radius + glowSize);
      gradient.addColorStop(0, color);
      gradient.addColorStop(0.4, color);
      gradient.addColorStop(1, 'transparent');
      ctx.beginPath();
      ctx.arc(x, y, radius + glowSize, 0, Math.PI * 2);
      ctx.fillStyle = gradient;
      ctx.fill();
    };

    const drawSun = (x, y) => {
      drawGlow(x, y, 50, '#fff4a3', 60);
      drawGlow(x, y, 50, '#ffd54f', 30);

      const sunGradient = ctx.createRadialGradient(x - 10, y - 10, 5, x, y, 50);
      sunGradient.addColorStop(0, '#fff9c4');
      sunGradient.addColorStop(0.5, '#ffeb3b');
      sunGradient.addColorStop(1, '#f57f17');
      ctx.beginPath();
      ctx.arc(x, y, 50, 0, Math.PI * 2);
      ctx.fillStyle = sunGradient;
      ctx.fill();
    };

    const drawEarth = (x, y) => {
      drawGlow(x, y, 18, 'rgba(100,180,255,0.3)', 12);

      const earthGradient = ctx.createRadialGradient(x - 5, y - 5, 2, x, y, 18);
      earthGradient.addColorStop(0, '#90caf9');
      earthGradient.addColorStop(0.4, '#1976d2');
      earthGradient.addColorStop(0.7, '#1565c0');
      earthGradient.addColorStop(1, '#0d47a1');
      ctx.beginPath();
      ctx.arc(x, y, 18, 0, Math.PI * 2);
      ctx.fillStyle = earthGradient;
      ctx.fill();

      ctx.beginPath();
      ctx.arc(x + 4, y - 4, 6, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(46,125,50,0.6)';
      ctx.fill();

      ctx.beginPath();
      ctx.arc(x - 6, y + 5, 5, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(46,125,50,0.5)';
      ctx.fill();

      ctx.beginPath();
      ctx.arc(x + 8, y + 8, 3, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(46,125,50,0.4)';
      ctx.fill();
    };

    const drawMoon = (x, y) => {
      drawGlow(x, y, 6, 'rgba(200,200,200,0.2)', 6);

      const moonGradient = ctx.createRadialGradient(x - 2, y - 2, 1, x, y, 6);
      moonGradient.addColorStop(0, '#fafafa');
      moonGradient.addColorStop(0.6, '#bdbdbd');
      moonGradient.addColorStop(1, '#757575');
      ctx.beginPath();
      ctx.arc(x, y, 6, 0, Math.PI * 2);
      ctx.fillStyle = moonGradient;
      ctx.fill();

      ctx.beginPath();
      ctx.arc(x + 2, y - 1, 1.5, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(0,0,0,0.15)';
      ctx.fill();

      ctx.beginPath();
      ctx.arc(x - 2, y + 2, 1, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(0,0,0,0.1)';
      ctx.fill();
    };

    const drawMars = (x, y) => {
      drawGlow(x, y, 12, 'rgba(255,100,50,0.2)', 8);

      const marsGradient = ctx.createRadialGradient(x - 3, y - 3, 1, x, y, 12);
      marsGradient.addColorStop(0, '#ff8a65');
      marsGradient.addColorStop(0.5, '#e64a19');
      marsGradient.addColorStop(1, '#bf360c');
      ctx.beginPath();
      ctx.arc(x, y, 12, 0, Math.PI * 2);
      ctx.fillStyle = marsGradient;
      ctx.fill();

      ctx.beginPath();
      ctx.arc(x, y - 10, 3, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(255,255,255,0.3)';
      ctx.fill();
    };

    const drawVenus = (x, y) => {
      drawGlow(x, y, 14, 'rgba(255,200,100,0.2)', 8);

      const venusGradient = ctx.createRadialGradient(x - 3, y - 3, 1, x, y, 14);
      venusGradient.addColorStop(0, '#ffe0b2');
      venusGradient.addColorStop(0.5, '#ffb74d');
      venusGradient.addColorStop(1, '#e65100');
      ctx.beginPath();
      ctx.arc(x, y, 14, 0, Math.PI * 2);
      ctx.fillStyle = venusGradient;
      ctx.fill();
    };

    const drawOrbit = (cx, cy, radius) => {
      ctx.beginPath();
      ctx.arc(cx, cy, radius, 0, Math.PI * 2);
      ctx.strokeStyle = 'rgba(255,255,255,0.06)';
      ctx.lineWidth = 1;
      ctx.stroke();
    };

    const drawShootingStar = (t) => {
      const cycle = t % 800;
      if (cycle > 60) return;

      const progress = cycle / 60;
      const startX = canvas.width * 0.7;
      const startY = canvas.height * 0.05;
      const x = startX - progress * 300;
      const y = startY + progress * 200;

      const tailGradient = ctx.createLinearGradient(x + 40, y - 25, x, y);
      tailGradient.addColorStop(0, 'transparent');
      tailGradient.addColorStop(1, 'rgba(255,255,255,0.8)');
      ctx.beginPath();
      ctx.moveTo(x, y);
      ctx.lineTo(x + 40, y - 25);
      ctx.strokeStyle = tailGradient;
      ctx.lineWidth = 2;
      ctx.stroke();

      ctx.beginPath();
      ctx.arc(x, y, 2, 0, Math.PI * 2);
      ctx.fillStyle = '#ffffff';
      ctx.fill();
    };

    const animate = () => {
      time += 0.008;
      ctx.fillStyle = '#0a0a1a';
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      const bgGradient = ctx.createRadialGradient(
        canvas.width / 2, canvas.height / 2, 0,
        canvas.width / 2, canvas.height / 2, canvas.width * 0.6
      );
      bgGradient.addColorStop(0, 'rgba(10,10,40,1)');
      bgGradient.addColorStop(0.5, 'rgba(5,5,25,1)');
      bgGradient.addColorStop(1, 'rgba(2,2,10,1)');
      ctx.fillStyle = bgGradient;
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      stars.forEach((star) => {
        const alpha = 0.4 + 0.6 * Math.sin(time * star.speed * 50 + star.twinkle);
        ctx.beginPath();
        ctx.arc(star.x * canvas.width, star.y * canvas.height, star.size, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(255,255,255,${alpha})`;
        ctx.fill();
      });

      drawShootingStar(Math.floor(time * 125));

      const cx = canvas.width / 2;
      const cy = canvas.height / 2;

      const venusOrbit = 120;
      const earthOrbit = 200;
      const marsOrbit = 300;

      drawOrbit(cx, cy, venusOrbit);
      drawOrbit(cx, cy, earthOrbit);
      drawOrbit(cx, cy, marsOrbit);

      const venusAngle = time * 1.6;
      const venusX = cx + Math.cos(venusAngle) * venusOrbit;
      const venusY = cy + Math.sin(venusAngle) * venusOrbit * 0.4;

      const earthAngle = time;
      const earthX = cx + Math.cos(earthAngle) * earthOrbit;
      const earthY = cy + Math.sin(earthAngle) * earthOrbit * 0.4;

      const moonAngle = time * 5;
      const moonOrbit = 35;
      const moonX = earthX + Math.cos(moonAngle) * moonOrbit;
      const moonY = earthY + Math.sin(moonAngle) * moonOrbit * 0.5;

      const marsAngle = time * 0.5;
      const marsX = cx + Math.cos(marsAngle) * marsOrbit;
      const marsY = cy + Math.sin(marsAngle) * marsOrbit * 0.4;

      const drawInOrder = [
        { y: venusY, draw: () => drawVenus(venusX, venusY), behind: venusY < cy },
        { y: earthY, draw: () => { drawEarth(earthX, earthY); drawMoon(moonX, moonY); }, behind: earthY < cy },
        { y: marsY, draw: () => drawMars(marsX, marsY), behind: marsY < cy },
      ];

      drawInOrder.filter(p => p.behind).forEach(p => p.draw());
      drawSun(cx, cy);
      drawInOrder.filter(p => !p.behind).forEach(p => p.draw());

      ctx.fillStyle = 'rgba(255,255,255,0.9)';
      ctx.font = 'bold 28px -apple-system, BlinkMacSystemFont, sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('React on AWS EC2', cx, canvas.height - 80);

      ctx.fillStyle = 'rgba(255,255,255,0.4)';
      ctx.font = '16px -apple-system, BlinkMacSystemFont, sans-serif';
      ctx.fillText('Deployed with Terraform + Atlantis', cx, canvas.height - 52);

      animationId = requestAnimationFrame(animate);
    };

    animate();

    return () => {
      cancelAnimationFrame(animationId);
      window.removeEventListener('resize', resize);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      style={{ display: 'block', background: '#0a0a1a', cursor: 'default' }}
    />
  );
}

export default App;
