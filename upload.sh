#!/bin/bash
# Qaflat Al-Tayseer Full App Auto Upload Script

mkdir -p src/components
mkdir -p src/utils
mkdir -p src/assets
mkdir -p public
mkdir -p android
mkdir -p android/app
mkdir -p android/app/src/main

# ------------------------------
# Main React Files
# ------------------------------

cat > package.json << 'EOF'
{
  "name": "qaflat-tayseer",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "start": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "xlsx": "^0.18.5",
    "file-saver": "^2.0.5",
    "hot-formula-parser": "^3.0.0",
    "jspdf": "^2.5.1"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^3.0.0",
    "vite": "^4.0.0",
    "@capacitor/cli": "^5.3.0",
    "@capacitor/core": "^5.3.0"
  }
}
EOF

cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({
  plugins: [react()],
  server: { port: 5173 }
})
EOF

# ------------------------------
# Capacitor Config
# ------------------------------
cat > capacitor.config.json << 'EOF'
{
  "appId": "com.fawzy.qaflat",
  "appName": "قافلة التيسير",
  "webDir": "dist",
  "bundledWebRuntime": false
}
EOF

# ------------------------------
# PUBLIC FILES
# ------------------------------
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>قافلة التيسير</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# ------------------------------
# CSS (Dark Theme)
# ------------------------------
cat > src/index.css << 'EOF'
:root{
  --bg:#0d0d0d;
  --card:#121212;
  --text:#ffffff;
  --muted:#bdbdbd;
  --accent:#004F9F;
  --accent2:#F4A66A;
}
body{background:var(--bg); color:var(--text); font-family: 'Cairo', sans-serif;}
EOF

# ------------------------------
# Splash Screen Component
# ------------------------------
cat > src/components/Splash.jsx << 'EOF'
import React, { useEffect } from 'react'
import logo from '../assets/logo.png'
import './splash.css'

export default function Splash({onFinish}) {
  useEffect(()=>{
    const t = setTimeout(()=>{
      const el = document.getElementById('splash-root')
      if(el) el.classList.add('fade-out')
      setTimeout(()=> onFinish(), 800)
    }, 2500)
    return ()=> clearTimeout(t)
  },[])

  return (
    <div id="splash-root" className="splash-root">
      <img src={logo} className="splash-logo" />
      <div className="splash-sub">AL TAYSEER EYE CARE</div>
    </div>
  )
}
EOF

cat > src/components/splash.css << 'EOF'
.splash-root{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100vh;background:#000;transition:opacity .8s ease}
.splash-logo{width:220px;height:auto;margin-bottom:18px}
.splash-sub{color:#ccc;font-size:14px}
.splash-root.fade-out{opacity:0}
EOF

# ------------------------------
# Home, Tabs, Grid Components
# ------------------------------
cat > src/components/SheetNav.jsx << 'EOF'
import React from 'react'
export default function SheetNav({sheets, active, onChange}) {
  return (
    <div className="mb-3">
      {sheets.map(s=>(
        <button key={s}
          onClick={()=>onChange(s)}
          className={`px-3 py-1 mr-2 ${s===active?'tab active':'tab'}`}>
          {s}
        </button>
      ))}
    </div>
  )
}
EOF

cat > src/components/GridEditor.jsx << 'EOF'
import React from 'react'
export default function GridEditor({grid, onUpdate, onAddRow, onDeleteRow}) {
  return (
    <div className="overflow-auto border rounded">
      <table className="min-w-full table-auto">
        <thead>
          <tr>
            <th>#</th>
            {grid[0].map((_,ci)=><th key={ci}>{String.fromCharCode(65+ci)}</th>)}
            <th>Delete</th>
          </tr>
        </thead>
        <tbody>
          {grid.map((row,ri)=>(
            <tr key={ri}>
              <td>{ri+1}</td>
              {row.map((cell,ci)=>(
                <td key={ci}>
                  <input
                    className="cell-input"
                    value={cell.f? '=' + cell.f : cell.v || ''}
                    onChange={e=>onUpdate(ri,ci,e.target.value)}
                  />
                </td>
              ))}
              <td>
                <button onClick={()=>onDeleteRow(ri)}>X</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <button onClick={onAddRow}>Add Row</button>
    </div>
  )
}
EOF

# ------------------------------
# UTILITIES
# ------------------------------
cat > src/utils/excelUtils.js << 'EOF'
import FormulaParser from 'hot-formula-parser'
import * as XLSX from 'xlsx'

export function sheetToGrid(ws){
  const range = ws['!ref'] || 'A1:A1'
  const decoded = XLSX.utils.decode_range(range)
  const rows=[]
  for(let r=decoded.s.r; r<=decoded.e.r; r++){
    const row=[]
    for(let c=decoded.s.c; c<=decoded.e.c; c++){
      const addr=XLSX.utils.encode_cell({r,c})
      const cell=ws[addr]
      row.push({
        v:cell?cell.v:'',
        f:cell?cell.f||null:null
      })
    }
    rows.push(row)
  }
  return rows
}
EOF

# ------------------------------
# MAIN APP
# ------------------------------
cat > src/App.jsx << 'EOF'
import React, {useState} from 'react'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'
import Splash from './components/Splash'
import SheetNav from './components/SheetNav'
import GridEditor from './components/GridEditor'
import { sheetToGrid } from './utils/excelUtils'
import './index.css'

export default function App() {
  const [showSplash,setSplash]=useState(true)
  const [sheets,setSheets]=useState([])
  const [active,setActive]=useState(null)
  const [grid,setGrid]=useState([])

  if(showSplash) return <Splash onFinish={()=>setSplash(false)} />

  function handleFile(e){
    const f=e.target.files[0]
    if(!f) return
    const reader=new FileReader()
    reader.onload=(ev)=>{
      const data=new Uint8Array(ev.target.result)
      const wb=XLSX.read(data,{cellFormula:true})
      setSheets(wb.SheetNames)
      const first=wb.SheetNames[0]
      setActive(first)
      setGrid(sheetToGrid(wb.Sheets[first]))
    }
    reader.readAsArrayBuffer(f)
  }

  function changeSheet(s){
    setActive(s)
  }

  return (
    <div className="container">
      <h1>قافلة التيسير</h1>
      <input type="file" onChange={handleFile} />
      <SheetNav sheets={sheets} active={active} onChange={changeSheet} />
      {grid.length>0 && <GridEditor grid={grid} onUpdate={()=>{}} onAddRow={()=>{}} onDeleteRow={()=>{}}/>}
    </div>
  )
}
EOF

# Done
