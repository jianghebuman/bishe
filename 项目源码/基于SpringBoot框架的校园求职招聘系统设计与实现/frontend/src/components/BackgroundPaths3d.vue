<template>
  <div class="background-paths-3d" :class="`is-${variant}`" aria-hidden="true">
    <svg viewBox="0 0 1200 720" preserveAspectRatio="none">
      <g class="paths-depth depth-back">
        <path
          v-for="path in backPaths"
          :key="path.id"
          :d="path.d"
          :style="path.style"
        />
      </g>
      <g class="paths-depth depth-front">
        <path
          v-for="path in frontPaths"
          :key="path.id"
          :d="path.d"
          :style="path.style"
        />
      </g>
    </svg>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: { type: String, default: 'light' },
  density: { type: Number, default: 18 }
})

const makePath = (index, count, depth = 0) => {
  const t = count > 1 ? index / (count - 1) : 0
  const x = 120 + t * 960
  const wave = Math.sin((t + depth * 0.18) * Math.PI * 2)
  const y = 120 + depth * 160 + wave * 52
  const bend = 150 + Math.cos(index * 0.7) * 58
  const rise = 170 + Math.sin(index * 0.5) * 46

  return {
    id: `${depth}-${index}`,
    d: `M ${x - 300} ${y + rise} C ${x - bend} ${y - 150}, ${x + bend} ${y + 160}, ${x + 330} ${y - 120}`,
    style: {
      '--path-index': index,
      '--path-alpha': 0.12 + (index % 5) * 0.03,
      '--path-width': `${1.1 + (index % 4) * 0.35}px`
    }
  }
}

const paths = computed(() => {
  const count = Math.max(8, Math.min(props.density, 32))
  return Array.from({ length: count }, (_, index) => makePath(index, count, 0))
})

const frontPaths = computed(() => paths.value.filter((_, index) => index % 2 === 0))
const backPaths = computed(() => paths.value.filter((_, index) => index % 2 === 1).map((path, index) => ({
  ...path,
  id: `back-${path.id}`,
  d: makePath(index, Math.max(backPathsCount.value, 1), 1).d
})))
const backPathsCount = computed(() => Math.ceil(paths.value.length / 2))
</script>

<style scoped>
.background-paths-3d {
  position: absolute;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  border-radius: inherit;
  pointer-events: none;
  opacity: var(--paths-3d-opacity, 0.58);
  mix-blend-mode: var(--paths-3d-blend, multiply);
  perspective: 900px;
}

.background-paths-3d svg {
  display: block;
  width: 100%;
  height: 100%;
  transform: rotateX(16deg) rotateZ(-4deg) translate3d(0, 0, 0);
  transform-origin: center;
  animation: paths-drift 18s ease-in-out infinite alternate;
}

.paths-depth {
  transform-box: fill-box;
  transform-origin: center;
}

.depth-back {
  opacity: 0.48;
  transform: scale(0.94) translate(32px, 34px);
  filter: blur(0.8px);
}

.depth-front {
  opacity: 0.92;
  transform: scale(1.03) translate(-12px, -18px);
}

.background-paths-3d path {
  fill: none;
  stroke: var(--paths-color-a, #2454d6);
  stroke-width: var(--path-width);
  stroke-linecap: round;
  stroke-dasharray: 190 34;
  stroke-dashoffset: calc(var(--path-index) * -42);
  opacity: var(--path-alpha);
  animation: path-flow 14s linear infinite;
  animation-delay: calc(var(--path-index) * -0.42s);
}

.background-paths-3d path:nth-child(3n + 1) {
  stroke: var(--paths-color-b, #0f766e);
}

.background-paths-3d path:nth-child(3n + 2) {
  stroke: var(--paths-color-c, #38bdf8);
}

.background-paths-3d.is-dark {
  --paths-color-a: #7dd3fc;
  --paths-color-b: #5eead4;
  --paths-color-c: #a5b4fc;
  mix-blend-mode: screen;
}

@keyframes paths-drift {
  from {
    transform: rotateX(16deg) rotateZ(-4deg) translate3d(-1.5%, -1%, 0);
  }
  to {
    transform: rotateX(20deg) rotateZ(-2deg) translate3d(1%, 1.5%, 0);
  }
}

@keyframes path-flow {
  to {
    stroke-dashoffset: calc(var(--path-index) * -42 - 224);
  }
}

@media (prefers-reduced-motion: reduce) {
  .background-paths-3d {
    opacity: calc(var(--paths-3d-opacity, 0.58) * 0.72);
  }

  .background-paths-3d svg,
  .background-paths-3d path {
    animation: none;
  }
}
</style>
