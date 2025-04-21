import gsap from 'https://cdn.skypack.dev/gsap@3.12.0'
import { ScrollTrigger } from 'https://cdn.skypack.dev/gsap@3.12.0/ScrollTrigger'
import { Pane } from 'https://cdn.skypack.dev/tweakpane@4.0.4'

let tl
let configureTimeline

const ctrl = new Pane({
  title: 'Config',
  expanded: true,
})

const scroller = document.querySelector('.scroller')
const list = scroller.querySelector('div')
const bar = scroller.querySelector('.scroller__bar')
const track = scroller.querySelector('.bar__track')
const thumb = bar.querySelector('.bar__thumb')
const styles = scroller.querySelector('style')

const config = {
  theme: 'dark',
  show: true,
  radius: 32,
  scrollPadding: 60,
  stroke: 5,
  inset: 6,
  trail: 20,
  thumb: 70,
  finish: 5,
  alpha: 0.9,
  track: 0,
  color: '#f85922',
  cornerLength: 0,
  offsetCorner: -50,
  offsetEnd: 30,
}

/**
 * Set up a ResizeObserver that syncs the SVG path and viewBox
 * with the size of the scroller. If you have a static sized scroller
 * and radius, etc. You can take a snapshot of it and use it over and over.
 * The ResizeObserver is mainly for demo purposes so you can make what you
 * want.
 * */
let frames = []
const syncBar = (scrollerBar) => {
  const mid = config.radius
  const innerRad = Math.max(
    0,
    config.radius - (config.inset + config.stroke * 0.5)
  )
  const padTop = config.inset + config.stroke * 0.5
  const padLeft = config.radius * 2 - padTop
  bar.setAttribute(
    'viewBox',
    `0 0 ${config.radius * 2} ${scrollerBar.target.offsetHeight}`
  )
  scroller.style.setProperty('--stroke-width', config.stroke)
  let d = `
  M${mid - config.trail},${padTop}
    ${innerRad === 0 ? '' : `L${mid},${padTop}`}
    ${
      innerRad === 0
        ? `L${padLeft},${padTop}`
        : `a${innerRad},${innerRad} 0 0 1 ${innerRad} ${innerRad}`
    }`
  thumb.setAttribute('d', d)
  const cornerLength = Math.ceil(thumb.getTotalLength())
  config.cornerLength = cornerLength
  d = `
    M${mid - config.trail},${padTop}
    ${innerRad === 0 ? '' : `L${mid},${padTop}`}
    ${
      innerRad === 0
        ? `L${padLeft},${padTop}`
        : `a${innerRad},${innerRad} 0 0 1 ${innerRad} ${innerRad}`
    }
    L${padLeft},${
    scrollerBar.target.offsetHeight -
    (config.inset + config.stroke * 0.5 + innerRad)
  }
    ${
      innerRad === 0
        ? `L${padLeft},${
            scrollerBar.target.offsetHeight -
            (config.inset + config.stroke * 0.5)
          }`
        : `a${innerRad},${innerRad} 0 0 1 ${-innerRad} ${innerRad}`
    }
    L${mid - config.trail},${
    scrollerBar.target.offsetHeight - (config.inset + config.stroke * 0.5)
  }
  `
  thumb.setAttribute('d', d)
  track.setAttribute('d', d)
  scroller.style.setProperty(
    '--track-length',
    Math.ceil(track.getTotalLength())
  )
  scroller.style.setProperty('--track-start', cornerLength)
  scroller.style.setProperty('--start', config.thumb * 2 + cornerLength)
  scroller.style.setProperty(
    '--destination',
    Math.ceil(track.getTotalLength()) - cornerLength + config.thumb
  )
  frames = [
    [0, config.thumb - config.finish - config.offsetEnd],
    [
      Math.floor(
        (config.scrollPadding / (list.scrollHeight - scroller.offsetHeight)) *
          100
      ),
      (cornerLength + config.offsetCorner) * -1,
    ],
    [
      100 -
        Math.floor(
          (config.scrollPadding / (list.scrollHeight - scroller.offsetHeight)) *
            100
        ),
      (Math.floor(track.getTotalLength()) -
        cornerLength -
        config.thumb -
        config.offsetCorner) *
        -1,
    ],
    [
      100,
      (Math.floor(track.getTotalLength()) - config.finish - config.offsetEnd) *
        -1,
    ],
  ]
  styles.innerHTML = `
    @keyframes scroll {
      ${frames[0][0]}% { stroke-dashoffset: ${frames[0][1]};}
      ${frames[1][0]}% { stroke-dashoffset: ${frames[1][1]};}
      ${frames[2][0]}% { stroke-dashoffset: ${frames[2][1]};}
      ${frames[3][0]}% { stroke-dashoffset: ${frames[3][1]};}
    }
  `
}

const resizeObserver = new ResizeObserver((entries) => {
  for (const entry of entries) {
    syncBar(entry)
    update()
    if (configureTimeline && !CSS.supports('animation-timeline: scroll()'))
      configureTimeline()
  }
})
resizeObserver.observe(scroller)

// if (config.show) document.documentElement.toggleAttribute('data-rounded-scroll')
// const configFolder = CTRL.addFolder('Config')
const update = () => {
  document.documentElement.dataset.theme = config.theme
  document.documentElement.dataset.roundedScroll = config.show
  scroller.style.setProperty('--radius', config.radius)
  scroller.style.setProperty('--padding', config.scrollPadding)
  scroller.style.setProperty('--color', config.color)
  scroller.style.setProperty('--thumb-size', config.thumb)
  scroller.style.setProperty('--bar-alpha', config.alpha)
  scroller.style.setProperty('--track-alpha', config.track)
  scroller.style.setProperty(
    '--destination',
    Math.ceil(track.getTotalLength()) -
      ((Math.ceil(track.getTotalLength()) - scroller.offsetHeight) * 0.5 +
        config.inset)
  )
  scroller.style.setProperty('--start', config.thumb * 2)
  syncBar({ target: list })
}

const setup = ctrl.addFolder({ title: 'setup', expanded: false })
setup.addBinding(config, 'radius', {
  min: 2,
  max: 64,
  step: 1,
  label: 'Radius',
})
setup.addBinding(config, 'scrollPadding', {
  min: 10,
  max: 200,
  step: 1,
  label: 'Padding',
})
setup.addBinding(config, 'stroke', {
  min: 1,
  max: 20,
  step: 1,
  label: 'Stroke',
})
setup.addBinding(config, 'inset', {
  min: 0,
  max: 20,
  step: 1,
  label: 'Inset',
})
setup.addBinding(config, 'trail', {
  min: 0,
  max: 100,
  step: 1,
  label: 'Trail',
})
setup.addBinding(config, 'thumb', {
  min: 20,
  max: 200,
  step: 1,
  label: 'Thumb',
})
setup.addBinding(config, 'thumb', {
  min: 5,
  max: 50,
  step: 1,
  label: 'Finish',
})
setup.addBinding(config, 'alpha', {
  min: 0.1,
  max: 1,
  step: 0.01,
  label: 'Thumb Alpha',
})
setup.addBinding(config, 'track', {
  min: 0.1,
  max: 1,
  step: 0.01,
  label: 'Track Alpha',
})
setup.addBinding(config, 'offsetCorner', {
  min: -50,
  max: 50,
  step: 1,
  label: 'Offset start',
})
setup.addBinding(config, 'offsetEnd', {
  min: -50,
  max: 50,
  step: 1,
  label: 'Offset end',
})
setup.addBinding(config, 'color', {
  label: 'Color',
})
ctrl.addBinding(config, 'show', {
  label: 'Enable',
})
ctrl.addBinding(config, 'theme', {
  label: 'Theme',
  options: {
    System: 'system',
    Light: 'light',
    Dark: 'dark',
  },
})
ctrl.on('change', update)

syncBar({ target: scroller })
if (!CSS.supports('(animation-timeline: scroll())')) {
  configureTimeline = () => {
    if (tl) tl.kill()
    tl = gsap.to('.bar__thumb', {
      scrollTrigger: {
        scroller: list,
        scrub: true,
      },
      ease: 'none',
      keyframes: {
        [`${frames[0][0]}`]: { strokeDashoffset: frames[0][1] },
        [`${frames[1][0]}`]: { strokeDashoffset: frames[1][1] },
        [`${frames[2][0]}`]: { strokeDashoffset: frames[2][1] },
        [`${frames[3][0]}`]: { strokeDashoffset: frames[3][1] },
      },
    })
  }
  gsap.registerPlugin(ScrollTrigger)
  configureTimeline()
}
