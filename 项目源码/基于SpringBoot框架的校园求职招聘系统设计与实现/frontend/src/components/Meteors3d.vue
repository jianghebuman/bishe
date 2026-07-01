<template>
  <div class="meteors-3d-field" aria-hidden="true">
    <span
      v-for="(style, index) in meteorStyles"
      :key="index"
      class="meteor-3d"
      :style="style"
    ></span>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'

const props = defineProps({
  number: { type: Number, default: 20 },
  minDelay: { type: Number, default: 0.2 },
  maxDelay: { type: Number, default: 1.2 },
  minDuration: { type: Number, default: 2 },
  maxDuration: { type: Number, default: 10 },
  angle: { type: Number, default: 215 },
  travel: { type: Number, default: 520 }
})

const meteorStyles = ref([])
const random = (min, max) => Math.random() * (max - min) + min

const buildMeteors = () => {
  const width = typeof window === 'undefined' ? 1440 : window.innerWidth
  meteorStyles.value = Array.from({ length: props.number }, () => {
    const depth = random(-90, 110)
    const scale = depth > 20 ? random(1.04, 1.42) : random(0.58, 1)

    return {
      '--meteor-angle': `${props.angle}deg`,
      '--meteor-depth': `${depth}px`,
      '--meteor-scale': scale.toFixed(2),
      '--meteor-opacity': random(0.48, 0.92).toFixed(2),
      '--meteor-travel': `${props.travel + random(-130, 150)}px`,
      '--meteor-tail': `${random(3.5, 7.4).toFixed(2)}rem`,
      '--meteor-blur': `${depth < -25 ? random(0.35, 0.9).toFixed(2) : random(0, 0.25).toFixed(2)}px`,
      top: `${random(-10, 24).toFixed(2)}%`,
      left: `${Math.floor(random(0, width))}px`,
      animationDelay: `${random(props.minDelay, props.maxDelay).toFixed(2)}s`,
      animationDuration: `${random(props.minDuration, props.maxDuration).toFixed(2)}s`
    }
  })
}

onMounted(buildMeteors)
watch(
  () => [props.number, props.minDelay, props.maxDelay, props.minDuration, props.maxDuration, props.angle, props.travel],
  buildMeteors
)
</script>

<style scoped>
.meteors-3d-field {
  position: absolute;
  inset: 0;
  overflow: hidden;
  border-radius: inherit;
  pointer-events: none;
  perspective: 900px;
  transform-style: preserve-3d;
}

.meteor-3d {
  position: absolute;
  width: 0.2rem;
  height: 0.2rem;
  border-radius: 999rem;
  opacity: 0;
  background: var(--meteor-color, rgba(96, 165, 250, 0.78));
  filter: blur(var(--meteor-blur));
  box-shadow:
    0 0 0 1px rgba(255, 255, 255, 0.14),
    0 0 1rem var(--meteor-glow, rgba(59, 130, 246, 0.24));
  transform: translateZ(var(--meteor-depth)) rotate(var(--meteor-angle)) translateX(0) scale(var(--meteor-scale));
  animation: meteor-3d-flight linear infinite;
  will-change: transform, opacity;
}

.meteor-3d::after {
  position: absolute;
  top: 50%;
  right: 0;
  width: var(--meteor-tail);
  height: 1px;
  content: "";
  border-radius: 999rem;
  background: linear-gradient(90deg, var(--meteor-tail-color, rgba(96, 165, 250, 0.58)), transparent);
  transform: translateY(-50%);
}

@keyframes meteor-3d-flight {
  0% {
    opacity: 0;
    transform: translateZ(var(--meteor-depth)) rotate(var(--meteor-angle)) translateX(0) scale(var(--meteor-scale));
  }

  12%,
  68% {
    opacity: var(--meteor-opacity);
  }

  100% {
    opacity: 0;
    transform: translateZ(var(--meteor-depth)) rotate(var(--meteor-angle)) translateX(calc(var(--meteor-travel) * -1)) scale(var(--meteor-scale));
  }
}

@media (prefers-reduced-motion: reduce) {
  .meteor-3d {
    display: none;
  }
}
</style>
