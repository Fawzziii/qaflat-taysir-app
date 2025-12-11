import React, { useEffect } from 'react'
import logo from '../assets/logo.png'
import './splash.css'

export default function Splash({ onFinish }) {

  useEffect(() => {
    const timer = setTimeout(() => {
      const el = document.getElementById('splash-root')
      if (el) el.classList.add('fade-out')
      setTimeout(() => onFinish(), 800)
    }, 2500)

    return () => clearTimeout(timer)
  }, [])

  return (
    <div id="splash-root" className="splash-root">
      <img src={logo} className="splash-logo" />
      <div className="splash-sub">AL TAYSEER EYE CARE</div>
    </div>
  )
}
