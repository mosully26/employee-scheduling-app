export function formatDate(date: string) {
  return new Date(date).toLocaleDateString([], {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });
}

export function formatDateWithWeekday(date: string) {
  return new Date(date).toLocaleDateString([], {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });
}

export function formatTime(date: string) {
  return new Date(date).toLocaleTimeString([], {
    hour: 'numeric',
    minute: '2-digit'
  });
}

export function formatDateTime(date: string) {
  return `${formatDateWithWeekday(date)} at ${formatTime(date)}`;
}

export function getInitials(name: string) {
  if (!name) return '?';

  return name
    .split(' ')
    .map((part) => part[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();
}

export function calculateShiftHours(start: string, end: string) {
  const startTime = new Date(start).getTime();
  const endTime = new Date(end).getTime();

  return Math.max(0, (endTime - startTime) / (1000 * 60 * 60));
}

export function formatHours(hours: number) {
  return `${hours.toFixed(2)} hrs`;
}