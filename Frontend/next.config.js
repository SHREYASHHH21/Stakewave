/** @type {import('next').NextConfig} */
const nextConfig = {
    images: {
        remotePatterns: [
          {
            protocol: "https",
            hostname: "assets.aceternity.com",
          },
          {
            protocol: "https",
            hostname: "images.ctfassets.net",
          },
          {
            protocol: "https",
            hostname: "cdn.tuk.dev",
          },
          {
            protocol: "https",
            hostname: "s2.coinmarketcap.com",
          },
          {
            protocol: "https",
            hostname: "https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/1168.jpg",
          },
          {
            protocol: "https",
            hostname: "avatars.githubusercontent.com",
          },
          {
            protocol: "https",
            hostname: "cloudflare-ipfs.com",
          },
          {
            protocol: "https",
            hostname: "cloudflare-ipfs.com",
          },
          {
            protocol: "https",
            hostname: "example.com",
          },
          {
            protocol: "https",
            hostname: "images.unsplash.com",
          },
          
          {
            protocol: "https",
            hostname: "randomuser.me",
          },
          {
            protocol: "https",
            hostname: "media.licdn.com",
          },
          
       
        ],
      },

}

module.exports = nextConfig
