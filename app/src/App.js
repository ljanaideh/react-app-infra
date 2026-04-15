import React, { useEffect, useRef } from 'react';

const MOON_SILVER = '#c5d4e8';

/** Must match planet position math: y uses radius * ORBIT_FLAT */
const ORBIT_FLAT = 0.38;

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

    const stars = Array.from({ length: 520 }, () => {
      const roll = Math.random();
      let layer = 'dim';
      if (roll > 0.88) layer = 'bright';
      else if (roll > 0.72) layer = 'mid';
      return {
        x: Math.random(),
        y: Math.random(),
        size: layer === 'dim' ? Math.random() * 0.9 + 0.15 : layer === 'mid' ? Math.random() * 1.3 + 0.4 : Math.random() * 2 + 1.2,
        twinkle: Math.random() * Math.PI * 2,
        speed: Math.random() * 0.022 + 0.004,
        warmth: Math.random(),
        layer,
      };
    });

    const drawGlow = (x, y, radius, color, glowSize) => {
      const gradient = ctx.createRadialGradient(x, y, radius * 0.3, x, y, radius + glowSize);
      gradient.addColorStop(0, color);
      gradient.addColorStop(0.45, color);
      gradient.addColorStop(1, 'transparent');
      ctx.beginPath();
      ctx.arc(x, y, radius + glowSize, 0, Math.PI * 2);
      ctx.fillStyle = gradient;
      ctx.fill();
    };

    const drawSun = (x, y, pulse) => {
      const r = 46 + pulse * 4;
      drawGlow(x, y, r, 'rgba(255,244,163,0.85)', 70 + pulse * 10);
      drawGlow(x, y, r, 'rgba(255,213,79,0.5)', 35);

      const sunGradient = ctx.createRadialGradient(x - 12, y - 12, 4, x, y, r);
      sunGradient.addColorStop(0, '#fffef5');
      sunGradient.addColorStop(0.35, '#fff59d');
      sunGradient.addColorStop(0.7, '#ffca28');
      sunGradient.addColorStop(1, '#e65100');
      ctx.beginPath();
      ctx.arc(x, y, r, 0, Math.PI * 2);
      ctx.fillStyle = sunGradient;
      ctx.fill();

      ctx.strokeStyle = `rgba(255,200,100,${0.12 + pulse * 0.08})`;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(x, y, r + 8 + pulse * 3, 0, Math.PI * 2);
      ctx.stroke();
    };

    const drawMercury = (x, y) => {
      drawGlow(x, y, 7, 'rgba(180,170,160,0.25)', 5);
      const g = ctx.createRadialGradient(x - 2, y - 2, 1, x, y, 7);
      g.addColorStop(0, '#e8e0d5');
      g.addColorStop(0.6, '#9e9e9e');
      g.addColorStop(1, '#5d4037');
      ctx.beginPath();
      ctx.arc(x, y, 7, 0, Math.PI * 2);
      ctx.fillStyle = g;
      ctx.fill();
      ctx.beginPath();
      ctx.arc(x + 3, y - 2, 1.2, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(0,0,0,0.2)';
      ctx.fill();
    };

    const drawEarth = (x, y, homePulse) => {
      const hb = 18 + homePulse * 1.5;
      drawGlow(x, y, hb, `rgba(100,180,255,${0.28 + homePulse * 0.12})`, 14);

      const earthGradient = ctx.createRadialGradient(x - 5, y - 5, 2, x, y, hb);
      earthGradient.addColorStop(0, '#b3e5fc');
      earthGradient.addColorStop(0.35, '#1976d2');
      earthGradient.addColorStop(0.65, '#0d47a1');
      earthGradient.addColorStop(1, '#01579b');
      ctx.beginPath();
      ctx.arc(x, y, hb, 0, Math.PI * 2);
      ctx.fillStyle = earthGradient;
      ctx.fill();

      ctx.beginPath();
      ctx.arc(x + 5, y - 4, 7, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(56,142,60,0.65)';
      ctx.fill();
      ctx.beginPath();
      ctx.arc(x - 7, y + 6, 5, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(46,125,50,0.5)';
      ctx.fill();
      ctx.beginPath();
      ctx.arc(x + 9, y + 9, 3, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(46,125,50,0.4)';
      ctx.fill();
    };

    const drawMoon = (x, y) => {
      drawGlow(x, y, 6, 'rgba(200,210,230,0.2)', 6);
      const moonGradient = ctx.createRadialGradient(x - 2, y - 2, 1, x, y, 6);
      moonGradient.addColorStop(0, '#f5f5f5');
      moonGradient.addColorStop(0.55, MOON_SILVER);
      moonGradient.addColorStop(1, '#78909c');
      ctx.beginPath();
      ctx.arc(x, y, 6, 0, Math.PI * 2);
      ctx.fillStyle = moonGradient;
      ctx.fill();
      ctx.beginPath();
      ctx.arc(x + 2, y - 1, 1.4, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(0,0,0,0.12)';
      ctx.fill();
    };

    const drawMars = (x, y) => {
      drawGlow(x, y, 11, 'rgba(255,100,50,0.22)', 8);
      const marsGradient = ctx.createRadialGradient(x - 3, y - 3, 1, x, y, 11);
      marsGradient.addColorStop(0, '#ffab91');
      marsGradient.addColorStop(0.5, '#e64a19');
      marsGradient.addColorStop(1, '#bf360c');
      ctx.beginPath();
      ctx.arc(x, y, 11, 0, Math.PI * 2);
      ctx.fillStyle = marsGradient;
      ctx.fill();
      ctx.beginPath();
      ctx.arc(x, y - 9, 2.5, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(255,255,255,0.35)';
      ctx.fill();
    };

    const drawVenus = (x, y) => {
      drawGlow(x, y, 13, 'rgba(255,200,120,0.2)', 8);
      const venusGradient = ctx.createRadialGradient(x - 3, y - 3, 1, x, y, 13);
      venusGradient.addColorStop(0, '#ffe0b2');
      venusGradient.addColorStop(0.45, '#ffb74d');
      venusGradient.addColorStop(1, '#e65100');
      ctx.beginPath();
      ctx.arc(x, y, 13, 0, Math.PI * 2);
      ctx.fillStyle = venusGradient;
      ctx.fill();
    };

    const drawJupiter = (x, y, rot) => {
      drawGlow(x, y, 22, 'rgba(255,200,160,0.15)', 18);
      const g = ctx.createRadialGradient(x - 6, y - 6, 2, x, y, 22);
      g.addColorStop(0, '#ffe0b2');
      g.addColorStop(0.3, '#d4a574');
      g.addColorStop(0.55, '#a1887f');
      g.addColorStop(0.75, '#8d6e63');
      g.addColorStop(1, '#5d4037');
      ctx.beginPath();
      ctx.arc(x, y, 22, 0, Math.PI * 2);
      ctx.fillStyle = g;
      ctx.fill();
      ctx.save();
      ctx.translate(x, y);
      ctx.rotate(rot);
      for (let i = -2; i <= 2; i++) {
        const yy = i * 5.5;
        ctx.beginPath();
        ctx.ellipse(0, yy, 20, 2.2, 0, 0, Math.PI * 2);
        ctx.fillStyle = i === 0 ? 'rgba(160,82,45,0.45)' : 'rgba(139,90,43,0.28)';
        ctx.fill();
      }
      ctx.beginPath();
      ctx.ellipse(8, -6, 9, 5, 0.3, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(183,28,28,0.55)';
      ctx.fill();
      ctx.restore();
    };

    const drawSaturn = (x, y, rot) => {
      ctx.save();
      ctx.translate(x, y);
      ctx.rotate(rot);
      const g = ctx.createRadialGradient(-4, -4, 2, 0, 0, 16);
      g.addColorStop(0, '#fff9c4');
      g.addColorStop(0.4, '#fdd835');
      g.addColorStop(0.75, '#f9a825');
      g.addColorStop(1, '#f57f17');
      ctx.beginPath();
      ctx.arc(0, 0, 16, 0, Math.PI * 2);
      ctx.fillStyle = g;
      ctx.fill();

      ctx.strokeStyle = 'rgba(255,224,130,0.55)';
      ctx.lineWidth = 2.5;
      ctx.beginPath();
      ctx.ellipse(0, 0, 28, 8, 0, 0, Math.PI * 2);
      ctx.stroke();
      ctx.strokeStyle = 'rgba(255,213,79,0.35)';
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.ellipse(0, 0, 32, 10, 0, 0, Math.PI * 2);
      ctx.stroke();
      ctx.beginPath();
      ctx.ellipse(0, 0, 24, 6, 0, 0, Math.PI * 2);
      ctx.strokeStyle = 'rgba(40,40,40,0.4)';
      ctx.stroke();
      ctx.restore();
    };

    const drawUranus = (x, y) => {
      drawGlow(x, y, 14, 'rgba(100,220,255,0.2)', 10);
      const g = ctx.createRadialGradient(x - 3, y - 3, 1, x, y, 14);
      g.addColorStop(0, '#b2ebf2');
      g.addColorStop(0.5, '#4dd0e1');
      g.addColorStop(1, '#006064');
      ctx.beginPath();
      ctx.arc(x, y, 14, 0, Math.PI * 2);
      ctx.fillStyle = g;
      ctx.fill();
      ctx.strokeStyle = 'rgba(178,235,242,0.4)';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.ellipse(x, y, 16, 4, 0.25, 0, Math.PI * 2);
      ctx.stroke();
    };

    const drawNeptune = (x, y) => {
      drawGlow(x, y, 13, 'rgba(80,100,255,0.2)', 10);
      const g = ctx.createRadialGradient(x - 3, y - 3, 1, x, y, 13);
      g.addColorStop(0, '#9fa8da');
      g.addColorStop(0.45, '#5c6bc0');
      g.addColorStop(0.85, '#283593');
      g.addColorStop(1, '#1a237e');
      ctx.beginPath();
      ctx.arc(x, y, 13, 0, Math.PI * 2);
      ctx.fillStyle = g;
      ctx.fill();
      ctx.beginPath();
      ctx.arc(x + 5, y - 4, 3, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(100,150,255,0.45)';
      ctx.fill();
    };

    /** Elliptical orbit matching planet math: rx = r, ry = r * ORBIT_FLAT */
    const drawOrbitEllipse = (ocx, ocy, rx, alpha = 0.08) => {
      const ry = rx * ORBIT_FLAT;
      ctx.beginPath();
      ctx.ellipse(ocx, ocy, rx, ry, 0, 0, Math.PI * 2);
      ctx.strokeStyle = `rgba(200,210,230,${alpha})`;
      ctx.lineWidth = 1;
      ctx.stroke();
    };

    const drawMoonOrbit = (ex, ey, moonRx, alpha) => {
      const ry = moonRx * ORBIT_FLAT;
      ctx.beginPath();
      ctx.ellipse(ex, ey, moonRx, ry, 0, 0, Math.PI * 2);
      ctx.strokeStyle = `rgba(180,195,220,${alpha})`;
      ctx.lineWidth = 0.8;
      ctx.stroke();
    };

    const drawShootingStar = (phase, w, h) => {
      const cycle = (time * 125 + phase) % 900;
      if (cycle > 55) return;
      const progress = cycle / 55;
      const startX = w * 0.75;
      const startY = h * 0.08;
      const x = startX - progress * 340;
      const y = startY + progress * 220;
      const tailGradient = ctx.createLinearGradient(x + 50, y - 30, x, y);
      tailGradient.addColorStop(0, 'transparent');
      tailGradient.addColorStop(0.5, 'rgba(200,230,255,0.7)');
      tailGradient.addColorStop(1, 'rgba(255,255,255,0.95)');
      ctx.beginPath();
      ctx.moveTo(x, y);
      ctx.lineTo(x + 50, y - 30);
      ctx.strokeStyle = tailGradient;
      ctx.lineWidth = 2;
      ctx.stroke();
      ctx.beginPath();
      ctx.arc(x, y, 2, 0, Math.PI * 2);
      ctx.fillStyle = '#fff';
      ctx.fill();
    };

    const drawRealisticBackground = (w, h, cx, cy, minDim) => {
      const g0 = ctx.createLinearGradient(0, 0, w, h * 1.1);
      g0.addColorStop(0, '#030508');
      g0.addColorStop(0.25, '#0a0e18');
      g0.addColorStop(0.55, '#0d1525');
      g0.addColorStop(1, '#02040a');
      ctx.fillStyle = g0;
      ctx.fillRect(0, 0, w, h);

      const mw = ctx.createLinearGradient(w * 0.1, h * 0.2, w * 0.95, h * 0.85);
      mw.addColorStop(0, 'rgba(25,35,55,0)');
      mw.addColorStop(0.35, 'rgba(55,65,95,0.12)');
      mw.addColorStop(0.5, 'rgba(80,90,120,0.08)');
      mw.addColorStop(0.65, 'rgba(45,50,75,0.1)');
      mw.addColorStop(1, 'rgba(20,25,40,0)');
      ctx.fillStyle = mw;
      ctx.fillRect(0, 0, w, h);

      const n1 = ctx.createRadialGradient(w * 0.15, h * 0.85, 0, w * 0.15, h * 0.85, minDim * 0.55);
      n1.addColorStop(0, 'rgba(40,30,70,0.2)');
      n1.addColorStop(0.5, 'rgba(30,40,80,0.08)');
      n1.addColorStop(1, 'rgba(0,0,0,0)');
      ctx.fillStyle = n1;
      ctx.fillRect(0, 0, w, h);

      const n2 = ctx.createRadialGradient(w * 0.88, h * 0.12, 0, w * 0.88, h * 0.12, minDim * 0.45);
      n2.addColorStop(0, 'rgba(25,55,90,0.18)');
      n2.addColorStop(0.6, 'rgba(20,40,70,0.06)');
      n2.addColorStop(1, 'rgba(0,0,0,0)');
      ctx.fillStyle = n2;
      ctx.fillRect(0, 0, w, h);

      const n3 = ctx.createRadialGradient(cx, cy, minDim * 0.15, cx, cy, minDim * 0.9);
      n3.addColorStop(0, 'rgba(15,25,45,0)');
      n3.addColorStop(1, 'rgba(0,0,0,0.5)');
      ctx.fillStyle = n3;
      ctx.fillRect(0, 0, w, h);
    };

    const animate = () => {
      time += 0.009;
      const w = canvas.width;
      const h = canvas.height;
      const cx = w / 2;
      const cy = h / 2;
      const minDim = Math.min(w, h);
      const R = minDim * 0.42;

      const sunPulse = Math.sin(time * 1.2) * 0.5 + 0.5;
      const homePulse = Math.sin(time * 0.9) * 0.5 + 0.5;

      drawRealisticBackground(w, h, cx, cy, minDim);

      stars.forEach((star) => {
        const tw = Math.sin(time * star.speed * 52 + star.twinkle);
        const alphaBase = star.layer === 'dim' ? 0.15 + tw * 0.15 : star.layer === 'mid' ? 0.35 + tw * 0.35 : 0.55 + tw * 0.35;
        const px = star.x * w;
        const py = star.y * h;
        const warm = star.warmth;
        const r = 200 + warm * 55;
        const g = 210 + warm * 45;
        const b = 255;

        if (star.layer === 'bright') {
          ctx.beginPath();
          ctx.arc(px, py, star.size * 1.8, 0, Math.PI * 2);
          ctx.fillStyle = `rgba(${r},${g},${b},${alphaBase * 0.15})`;
          ctx.fill();
        }
        ctx.beginPath();
        ctx.arc(px, py, star.size, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(${r},${g},${b},${alphaBase})`;
        ctx.fill();
      });

      drawShootingStar(0, w, h);
      drawShootingStar(400, w, h);

      const orbit = (n) => R * n;

      const mercuryR = orbit(0.22);
      const venusR = orbit(0.3);
      const earthR = orbit(0.38);
      const marsR = orbit(0.46);
      const jupiterR = orbit(0.58);
      const saturnR = orbit(0.7);
      const uranusR = orbit(0.82);
      const neptuneR = orbit(0.94);

      [
        mercuryR, venusR, earthR, marsR,
        jupiterR, saturnR, uranusR, neptuneR,
      ].forEach((r, i) => drawOrbitEllipse(cx, cy, r, 0.06 + i * 0.01));

      const a = (speed) => time * speed;
      const pos = (r, speed, offset = 0) => ({
        x: cx + Math.cos(a(speed) + offset) * r,
        y: cy + Math.sin(a(speed) + offset) * r * ORBIT_FLAT,
      });

      const mercury = pos(mercuryR, 2.15);
      const venus = pos(venusR, 1.65);
      const earth = pos(earthR, 1.12);
      const mars = pos(marsR, 0.72);
      const jupiter = pos(jupiterR, 0.22);
      const saturn = pos(saturnR, 0.14);
      const uranus = pos(uranusR, 0.095);
      const neptune = pos(neptuneR, 0.062);

      const moonAngle = time * 4.8;
      const moonDist = minDim * 0.068;
      const moon = {
        x: earth.x + Math.cos(moonAngle) * moonDist,
        y: earth.y + Math.sin(moonAngle) * moonDist * ORBIT_FLAT,
      };

      const jupiterSpin = time * 0.4;
      const saturnSpin = time * 0.35;

      drawMoonOrbit(earth.x, earth.y, moonDist, 0.14);

      const layers = [
        { z: mercury.y, draw: () => drawMercury(mercury.x, mercury.y) },
        { z: venus.y, draw: () => drawVenus(venus.x, venus.y) },
        {
          z: earth.y,
          draw: () => {
            drawEarth(earth.x, earth.y, homePulse);
            drawMoon(moon.x, moon.y);
          },
        },
        { z: mars.y, draw: () => drawMars(mars.x, mars.y) },
        { z: jupiter.y, draw: () => drawJupiter(jupiter.x, jupiter.y, jupiterSpin) },
        { z: saturn.y, draw: () => drawSaturn(saturn.x, saturn.y, saturnSpin) },
        { z: uranus.y, draw: () => drawUranus(uranus.x, uranus.y) },
        { z: neptune.y, draw: () => drawNeptune(neptune.x, neptune.y) },
      ];

      const behind = layers.filter((l) => l.z < cy);
      const front = layers.filter((l) => l.z >= cy);

      behind.sort((a, b) => a.z - b.z);
      front.sort((a, b) => a.z - b.z);

      behind.forEach((l) => l.draw());
      drawSun(cx, cy, sunPulse);
      front.forEach((l) => l.draw());

      ctx.fillStyle = 'rgba(255,255,255,0.95)';
      ctx.font = 'bold 26px -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif';
      ctx.textAlign = 'center';
      ctx.shadowColor = 'rgba(0,40,100,0.8)';
      ctx.shadowBlur = 12;
      ctx.fillText('React on AWS EC2', cx, h - 80);
      ctx.shadowBlur = 0;

      ctx.fillStyle = 'rgba(200,215,235,0.55)';
      ctx.font = '15px -apple-system, BlinkMacSystemFont, sans-serif';
      ctx.fillText('Terraform · Atlantis · Docker · EC2', cx, h - 48);

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
      style={{ display: 'block', background: '#030508', cursor: 'default' }}
    />
  );
}

export default App;
