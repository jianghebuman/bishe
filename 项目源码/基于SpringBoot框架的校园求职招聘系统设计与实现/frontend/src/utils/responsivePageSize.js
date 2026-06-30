import { nextTick, onBeforeUnmount } from 'vue'

export function useResponsivePageSize(targetRef, query, load, options = {}) {
  const itemMinWidth = options.itemMinWidth ?? 320
  const itemMinHeight = options.itemMinHeight ?? 240
  const gap = options.gap ?? 16
  const fallbackRows = options.rows ?? options.fallbackRows ?? 2
  const fixedColumns = options.columns ?? 0
  const minRows = options.minRows ?? 1
  const minPageSize = options.minPageSize ?? 1
  const maxPageSize = options.maxPageSize ?? 30
  const delay = options.delay ?? 160
  const bottomReserve = options.bottomReserve ?? 0
  const pagerReserve = options.pagerReserve ?? 0
  const fitViewport = options.fitViewport !== false
  let resizeTimer
  let resizeObserver
  let watchingWindow = false

  const getNumber = (value) => {
    if (!value || value === 'normal') return 0
    const match = String(value).match(/[\d.]+/)
    return match ? Number(match[0]) : 0
  }

  const getTrackCount = (tracks) => {
    if (!tracks || tracks === 'none') return 0
    return tracks.trim().split(/\s+/).filter(Boolean).length
  }

  const getFirstItemHeight = (target) => {
    const item = Array.from(target.children || []).find((child) => {
      const classes = child.classList
      return !classes.contains('el-loading-mask') && !classes.contains('grid-empty') && !classes.contains('el-empty')
    })
    return item?.getBoundingClientRect().height || 0
  }

  const syncCardHeight = (card) => {
    if (!fitViewport || !card) return
    const viewportHeight = window.innerHeight || document.documentElement.clientHeight || 0
    const top = Math.max(0, card.getBoundingClientRect().top)
    const height = Math.floor(viewportHeight - top - bottomReserve)
    if (height > 0) card.style.setProperty('--portal-list-card-min-height', `${height}px`)
  }

  const getAvailableHeight = (target) => {
    const scroll = target?.closest('.page-flex-scroll')
    const card = target?.closest('.page-flex-card')
    if (!scroll || !card) return target?.parentElement?.clientHeight || 0

    syncCardHeight(card)
    const style = window.getComputedStyle(card)
    const pager = card.querySelector(':scope > .pagination-wrap')
    if (!pager) return scroll.clientHeight || 0

    const viewportHeight = window.innerHeight || document.documentElement.clientHeight || 0
    const scrollTop = Math.max(0, scroll.getBoundingClientRect().top)
    const paddingBottom = parseFloat(style.paddingBottom) || 0
    const viewportHeightLeft = viewportHeight - scrollTop - pager.offsetHeight - paddingBottom - bottomReserve - pagerReserve
    if (viewportHeightLeft > 0) return viewportHeightLeft

    const minHeight = parseFloat(style.minHeight) || 0
    const paddingY = (parseFloat(style.paddingTop) || 0) + (parseFloat(style.paddingBottom) || 0)
    const cardHeight = Math.max(card.clientHeight || 0, minHeight)
    return Math.max(scroll.clientHeight || 0, cardHeight - paddingY - pager.offsetHeight - pagerReserve)
  }

  const getPageSize = () => {
    const target = targetRef.value
    const width = target?.clientWidth || 0
    if (!width) return query.pageSize
    const style = window.getComputedStyle(target)
    const columnGap = getNumber(style.columnGap || style.gap) || gap
    const rowGap = getNumber(style.rowGap || style.gap) || gap
    const columns = fixedColumns || getTrackCount(style.gridTemplateColumns) || Math.max(1, Math.floor((width + columnGap) / (itemMinWidth + columnGap)))
    const rowHeight = getFirstItemHeight(target) || getNumber(style.gridAutoRows) || itemMinHeight
    const height = getAvailableHeight(target)
    const rows = height ? Math.max(minRows, Math.floor((height + rowGap) / (rowHeight + rowGap))) : fallbackRows
    return Math.min(maxPageSize, Math.max(minPageSize, columns * rows))
  }

  const syncPageSize = () => {
    const nextSize = getPageSize()
    if (!nextSize || nextSize === query.pageSize) return false
    query.pageSize = nextSize
    query.pageNum = 1
    return true
  }

  const handleResize = () => {
    clearTimeout(resizeTimer)
    resizeTimer = setTimeout(() => {
      if (syncPageSize()) load()
    }, delay)
  }

  const watchTarget = () => {
    const target = targetRef.value
    if (target && 'ResizeObserver' in window) {
      resizeObserver = new ResizeObserver(handleResize)
      resizeObserver.observe(target)
      if (target.parentElement) resizeObserver.observe(target.parentElement)
      return
    }
    window.addEventListener('resize', handleResize)
    watchingWindow = true
  }

  const initResponsivePageSize = async () => {
    await nextTick()
    syncPageSize()
    watchTarget()
  }

  onBeforeUnmount(() => {
    resizeObserver?.disconnect()
    if (watchingWindow) window.removeEventListener('resize', handleResize)
    clearTimeout(resizeTimer)
  })

  return { initResponsivePageSize }
}
