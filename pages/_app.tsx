import '../styles/globals.css'
import type { AppProps } from 'next/app'
import { ThemeProvider } from 'next-themes'
import { Footer, Navbar } from '../components'

import Script from 'next/script'


export default function App({ Component, pageProps }: AppProps) {
  return (
    <ThemeProvider attribute="class">
      <main className='dark:bg-nft bg-white min-h-screen'>
        <Navbar />
        <div className='pt-65 dark:bg-black'>
          <Component {...pageProps} />
        </div>
        <Footer />
      </main>

      <Script src="https://kit.fontawesome.com/be0aa75a79.js" crossOrigin="anonymous" />

    </ThemeProvider>
  )
}
