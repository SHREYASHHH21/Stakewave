import React from "react";

interface GridBackgroundProps {

  children: React.ReactNode;
}

const GridBackground: React.FC<GridBackgroundProps> = ({
  children,


}) => {
  return (
    <div
    className={`relative  bg-black pt-40 overflow-hidden px-2 bg-grid-white/[0.2]  `}
  >
      {/* Radial gradient for the container to give a faded look */}
      <div className="absolute  pointer-events-none inset-0 flex items-center justify-center dark:bg-black bg-white [mask-image:radial-gradient(ellipse_at_center,transparent_50%,black)]">
      </div>
      {children}

    </div>
  );
};

export default GridBackground;
