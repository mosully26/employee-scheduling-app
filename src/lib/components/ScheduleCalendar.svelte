<script lang="ts">
  import { SvelteDate } from 'svelte/reactivity';

  type Shift = {
    id?: string | number;
    title?: string;
    start_time?: string;
    end_time?: string;
    shift_role?: string;
    color?: string | null;
  };

  let {
    shifts = [],
    view = 'week'
  }: {
    shifts: Shift[];
    view: 'day' | 'week' | 'month';
  } = $props();

  const hours = [
    8, 9, 10, 11, 12,
    13, 14, 15, 16, 17,
    18, 19, 20
  ];
  const scheduleStartHour = 8;
  const scheduleEndHour = 21;
  const pixelsPerMinute = 1.25;

  const weekDays = $derived.by(() => {
    const start = new SvelteDate();
    start.setHours(0, 0, 0, 0);

    return Array.from({ length: 10 }, (_, index) => {
      const date = new SvelteDate(start);
      date.setDate(start.getDate() + index);
      return date;
    });
  });

  const monthLabel = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  const monthDays = $derived.by(() => {
    const now = new SvelteDate();
    const startOfMonth = new SvelteDate(now.getFullYear(), now.getMonth(), 1);
    const daysInMonth = new SvelteDate(now.getFullYear(), now.getMonth() + 1, 0).getDate();
    const days: (SvelteDate | null)[] = Array.from(
      { length: startOfMonth.getDay() },
      () => null
    );

    for (let day = 1; day <= daysInMonth; day += 1) {
      days.push(new SvelteDate(now.getFullYear(), now.getMonth(), day));
    }

    return days;
  });

  const monthTitle = $derived.by(() => {
    const now = new SvelteDate();
    return now.toLocaleDateString([], { month: 'long', year: 'numeric' });
  });

  const dayViewDate = $derived.by(() => {
    const date = new SvelteDate();
    date.setHours(0, 0, 0, 0);
    return date;
  });

  function formatDay(date: Date) {
    return date.toLocaleDateString([], {
      weekday: 'short'
    });
  }

  function formatDate(date: Date) {
    return date.toLocaleDateString([], {
      month: 'short',
      day: 'numeric'
    });
  }

  function formatHour(hour: number) {
    const date = new SvelteDate();
    date.setHours(hour, 0, 0, 0);

    return date.toLocaleTimeString([], {
      hour: 'numeric'
    });
  }

  function sameDay(dateA: string | undefined, dateB: Date) {
    if (!dateA) return false;

    const dateKey = `${dateB.getFullYear()}-${String(dateB.getMonth() + 1).padStart(2, '0')}-${String(dateB.getDate()).padStart(2, '0')}`;
    return dateA.slice(0, 10) === dateKey;
  }

  function shiftsForDay(date: Date) {
    return shifts.filter((shift) => sameDay(shift.start_time, date));
  }

  function isCurrentMonth(date: Date) {
    const now = new SvelteDate();
    return date.getMonth() === now.getMonth() && date.getFullYear() === now.getFullYear();
  }

  function isToday(date: Date) {
    const now = new SvelteDate();
    return (
      now.getFullYear() === date.getFullYear() &&
      now.getMonth() === date.getMonth() &&
      now.getDate() === date.getDate()
    );
  }

  function formatShiftTime(date: string | undefined) {
    if (!date) return '—';

    const timePart = date.split('T')[1]?.slice(0, 5);
    if (timePart) {
      const [hours, minutes] = timePart.split(':').map(Number);
      if (!Number.isNaN(hours) && !Number.isNaN(minutes)) {
        const clock = new SvelteDate();
        clock.setHours(hours, minutes, 0, 0);
        return clock.toLocaleTimeString([], {
          hour: 'numeric',
          minute: '2-digit'
        });
      }
    }

    return new SvelteDate(date).toLocaleTimeString([], {
      hour: 'numeric',
      minute: '2-digit'
    });
  }

  function getClockMinutes(date: string | undefined) {
    if (!date) return null;

    const timePart = date.split('T')[1]?.slice(0, 5);
    if (!timePart) return null;

    const [hours, minutes] = timePart.split(':').map(Number);
    if (Number.isNaN(hours) || Number.isNaN(minutes)) return null;

    return hours * 60 + minutes;
  }

  function getShiftTop(startTime: string | undefined) {
    const clockMinutes = getClockMinutes(startTime);
    if (clockMinutes === null) return 0;

    const minutesFromStart = clockMinutes - scheduleStartHour * 60;
    const maxTop = (scheduleEndHour - scheduleStartHour) * 60 - 45;

    return Math.max(0, Math.min(minutesFromStart * pixelsPerMinute, maxTop * pixelsPerMinute));
  }

  function getShiftHeight(startTime: string | undefined, endTime: string | undefined) {
    const startMinutes = getClockMinutes(startTime);
    const endMinutes = getClockMinutes(endTime);
    if (startMinutes === null || endMinutes === null || endMinutes <= startMinutes) return 45;

    const clippedStart = Math.max(startMinutes, scheduleStartHour * 60);
    const clippedEnd = Math.min(endMinutes, scheduleEndHour * 60);
    const durationMinutes = Math.max(clippedEnd - clippedStart, 0);

    return Math.max(Math.min(durationMinutes * pixelsPerMinute, (scheduleEndHour - scheduleStartHour) * 60 * pixelsPerMinute), 45);
  }
</script>

<div class="rounded-3xl bg-white p-6 shadow-md">
  <div class="mb-6">
    <h2 class="text-2xl font-bold text-[#6b4f4f]">
      Schedule
    </h2>

    <p class="text-sm text-[#9c7b7b]">
      {view === 'day'
        ? 'Day View'
        : view === 'week'
          ? 'Next 10 Days'
          : 'Month View'}
    </p>
  </div>

  {#if shifts.length === 0}
    <div
      class="rounded-2xl border border-dashed border-[#ead8d8] p-8 text-center"
    >
      <p class="text-[#9c7b7b]">
        No scheduled shifts to display.
      </p>
    </div>

  {:else if view === 'week'}

    <div class="overflow-x-auto">
      <div class="min-w-330">

        <!-- DAYS HEADER -->
        <div
          class="grid border-b border-[#ead8d8]"
          style="grid-template-columns: 80px repeat(10, minmax(110px, 1fr));"
        >
          <div></div>

          {#each weekDays as day (day.toISOString())}
            <div class="border-l border-[#ead8d8] p-3 text-center">
              <p class="font-semibold text-[#6b4f4f]">
                {formatDay(day)}
              </p>

              <p class="text-sm text-[#9c7b7b]">
                {formatDate(day)}
              </p>
            </div>
          {/each}
        </div>

        <!-- CALENDAR BODY -->
        <div
          class="relative grid"
          style="grid-template-columns: 80px repeat(10, minmax(110px, 1fr));"
        >

          <!-- TIME LABELS -->
          <div>
            {#each hours as hour (hour)}
              <div
                class="h-18.75 border-b border-[#f1e4e4] pr-3 pt-2 text-right"
                data-hour={hour}
              >
                <span class="text-xs text-[#9c7b7b]">
                  {formatHour(hour)}
                </span>
              </div>
            {/each}
          </div>

          <!-- EACH DAY -->
          {#each weekDays as day (day.toISOString())}
            <div
              class="relative border-l border-[#ead8d8]"
              style={`height: ${hours.length * 75}px`}
            >

              <!-- HOUR LINES -->
              {#each hours as hour (hour)}
                <div
                  class="h-18.75 border-b border-[#f1e4e4]"
                  data-hour={hour}
                ></div>
              {/each}

              <!-- SHIFTS -->
              {#each shiftsForDay(day) as shift (shift.id ?? `${shift.title ?? 'shift'}-${shift.start_time ?? 'time'}`)}
                <div
                  class="absolute left-2 right-2 overflow-hidden rounded-xl border-l-4 bg-[#fff0f6] p-3 shadow-sm"
                  style={`
                    top: ${getShiftTop(shift.start_time)}px;
                    height: ${getShiftHeight(
                      shift.start_time,
                      shift.end_time
                    )}px;
                    border-left-color: ${shift.color || '#ff2d96'};
                  `}
                >
                  <p
                    class="truncate text-sm font-bold text-[#6b4f4f]"
                  >
                    {shift.title}
                  </p>

                  <p class="mt-1 text-xs text-[#7d6161]">
                    {formatShiftTime(shift.start_time)}
                    -
                    {formatShiftTime(shift.end_time)}
                  </p>

                  {#if shift.shift_role}
                    <p
                      class="mt-1 truncate text-xs text-[#9c7b7b]"
                    >
                      {shift.shift_role}
                    </p>
                  {/if}
                </div>
              {/each}

            </div>
          {/each}
        </div>
      </div>
    </div>

  {:else if view === 'day'}
    <div class="overflow-x-auto">
      <div class="min-w-210">
        <div
          class="grid border-b border-[#ead8d8]"
          style="grid-template-columns: 80px minmax(180px, 1fr);"
        >
          <div></div>
          <div class="border-l border-[#ead8d8] p-3 text-center">
            <p class="font-semibold text-[#6b4f4f]">{formatDay(dayViewDate)}</p>
            <p class="text-sm text-[#9c7b7b]">{formatDate(dayViewDate)}</p>
          </div>
        </div>

        <div
          class="relative grid"
          style="grid-template-columns: 80px minmax(180px, 1fr);"
        >
          <div>
            {#each hours as hour (hour)}
              <div class="h-18.75 border-b border-[#f1e4e4] pr-3 pt-2 text-right" data-hour={hour}>
                <span class="text-xs text-[#9c7b7b]">{formatHour(hour)}</span>
              </div>
            {/each}
          </div>

          <div
            class="relative border-l border-[#ead8d8]"
            style={`height: ${hours.length * 75}px`}
          >
            {#each hours as hour (hour)}
              <div class="h-18.75 border-b border-[#f1e4e4]" data-hour={hour}></div>
            {/each}

            {#each shiftsForDay(dayViewDate) as shift (shift.id ?? `${shift.title ?? 'shift'}-${shift.start_time ?? 'time'}`)}
              <div
                class="absolute left-2 right-2 overflow-hidden rounded-xl border-l-4 bg-[#fff0f6] p-3 shadow-sm"
                style={`
                  top: ${getShiftTop(shift.start_time)}px;
                  height: ${getShiftHeight(shift.start_time, shift.end_time)}px;
                  border-left-color: ${shift.color || '#ff2d96'};
                `}
              >
                <p class="truncate text-sm font-bold text-[#6b4f4f]">{shift.title || 'Scheduled shift'}</p>
                <p class="mt-1 text-xs text-[#7d6161]">
                  {formatShiftTime(shift.start_time)} - {formatShiftTime(shift.end_time)}
                </p>
                {#if shift.shift_role}
                  <p class="mt-1 truncate text-xs text-[#9c7b7b]">{shift.shift_role}</p>
                {/if}
              </div>
            {/each}
          </div>
        </div>
      </div>
    </div>
  {:else}

    <div class="overflow-x-auto">
      <div class="min-w-210">
        <div class="mb-4 flex items-center justify-between rounded-2xl bg-[#fff4f6] px-4 py-3">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.18em] text-[#b28b93]">Your schedule</p>
            <p class="text-xl font-bold text-[#6b4f4f]">{monthTitle}</p>
          </div>
          <p class="text-sm text-[#9c7b7b]">Your assigned shifts</p>
        </div>

        <div class="grid grid-cols-7 gap-2 text-center">
          {#each monthLabel as label (label)}
            <div class="px-2 py-3 text-xs font-semibold uppercase tracking-[0.18em] text-[#9c7b7b]">
              {label}
            </div>
          {/each}

          {#each monthDays as day, index (`month-day-${index}`)}
            {#if day}
              <div
                class={`min-h-28 rounded-2xl border p-2 ${
                  isCurrentMonth(day)
                    ? 'border-[#f1e4e4] bg-white'
                    : 'border-[#f9eef1] bg-[#fffafc] text-[#c2a0a8]'
                } ${isToday(day) ? 'ring-2 ring-[#ff2d96]/40' : ''}`}
              >
                <div class="mb-2 flex items-center justify-between">
                  <span class="text-sm font-semibold text-[#6b4f4f]">{day.getDate()}</span>
                </div>

                <div class="space-y-1.5">
                  {#each shiftsForDay(day).slice(0, 3) as shift (shift.id ?? `${shift.title ?? 'shift'}-${shift.start_time ?? 'time'}-${day.toISOString()}`)}
                    <div
                      class="rounded-lg border-l-4 px-2 py-1 text-left text-[11px] text-[#6b4f4f]"
                      style={`border-left-color: ${shift.color || '#ff2d96'}; background: ${shift.color ? `${shift.color}18` : '#fff0f6'}`}
                    >
                      <p class="truncate font-semibold">{shift.title || 'Scheduled shift'}</p>
                      <p class="truncate text-[10px] opacity-80">{formatShiftTime(shift.start_time)}</p>
                    </div>
                  {/each}

                  {#if shiftsForDay(day).length > 3}
                    <p class="text-[10px] font-medium text-[#9c7b7b]">
                      +{shiftsForDay(day).length - 3} more
                    </p>
                  {/if}
                </div>
              </div>
            {:else}
              <div class="min-h-28 rounded-2xl bg-transparent"></div>
            {/if}
          {/each}
        </div>
      </div>
    </div>

  {/if}
</div>