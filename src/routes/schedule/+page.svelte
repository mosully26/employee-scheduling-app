<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import ScheduleCalendar from '$lib/components/ScheduleCalendar.svelte';

  let profile = $state<any>(null);
  let shifts = $state<any[]>([]);
  let loading = $state(true);
  let error = $state('');
  let sidebarOpen = $state(false);
  let view = $state<'day' | 'week' | 'month'>('week');

  onMount(async () => {
    try {
      const {
        data: { user }
      } = await supabase.auth.getUser();

      if (!user) {
        window.location.href = '/login';
        return;
      }

      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id);

      if (profileError) {
        error = profileError.message;
        return;
      }

      profile = Array.isArray(profileData) ? profileData[0] : profileData;

      const { data, error: shiftsError } = await supabase
        .from('shifts')
        .select('*')
        .eq('employee_id', user.id)
        .order('start_time', { ascending: true });

      if (shiftsError) {
        error = shiftsError.message;
        return;
      }

      shifts = data ?? [];
    } catch (err) {
      console.error(err);
      error = 'Something went wrong loading your schedule.';
    } finally {
      loading = false;
    }
  });

  function sameDay(a: string, b: Date) {
    const d = new Date(a);
    return (
      d.getFullYear() === b.getFullYear() &&
      d.getMonth() === b.getMonth() &&
      d.getDate() === b.getDate()
    );
  }

  function inCurrentWeek(date: string) {
    const d = new Date(date);
    const now = new Date();
    const start = new Date(now);
    const day = start.getDay();

    start.setDate(now.getDate() - day);
    start.setHours(0, 0, 0, 0);

    const end = new Date(start);
    end.setDate(start.getDate() + 7);

    return d >= start && d < end;
  }

  function inCurrentMonth(date: string) {
    const d = new Date(date);
    const now = new Date();
    return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
  }

  const filteredShifts = $derived.by(() => {
    const now = new Date();

    if (view === 'day') {
      return shifts.filter((shift) => sameDay(shift.start_time, now));
    }

    if (view === 'week') {
      return shifts.filter((shift) => inCurrentWeek(shift.start_time));
    }

    return shifts.filter((shift) => inCurrentMonth(shift.start_time));
  });
</script>

<div class="min-h-screen bg-[#fff9f8]">
  <Sidebar profile={profile} bind:isOpen={sidebarOpen} />

  <div class="md:ml-72">
    <div class="sticky top-0 z-20 border-b border-[#efd9dd] bg-white/90 backdrop-blur">
      <div class="flex items-center justify-between px-4 py-4 md:px-6">
        <div class="flex items-center gap-3">
          <button
            type="button"
            class="rounded-lg bg-[#f7edee] px-3 py-2 text-[#6b4f4f] md:hidden"
            onclick={() => (sidebarOpen = true)}
          >
            Menu
          </button>

          <div>
            <p class="text-lg font-bold text-[#6b4f4f]">Schedule</p>
            <p class="text-sm text-[#9c7b7b]">View your day, week, and month shifts</p>
          </div>
        </div>

        <div class="hidden gap-2 md:flex">
          <button
            type="button"
            onclick={() => (view = 'day')}
            class={`rounded-lg px-4 py-2 ${
              view === 'day'
                ? 'bg-[#ff2d96] text-white'
                : 'bg-[#f7edee] text-[#6b4f4f]'
            }`}
          >
            Day
          </button>

          <button
            type="button"
            onclick={() => (view = 'week')}
            class={`rounded-lg px-4 py-2 ${
              view === 'week'
                ? 'bg-[#ff2d96] text-white'
                : 'bg-[#f7edee] text-[#6b4f4f]'
            }`}
          >
            Week
          </button>

          <button
            type="button"
            onclick={() => (view = 'month')}
            class={`rounded-lg px-4 py-2 ${
              view === 'month'
                ? 'bg-[#ff2d96] text-white'
                : 'bg-[#f7edee] text-[#6b4f4f]'
            }`}
          >
            Month
          </button>
        </div>
      </div>
    </div>

    <main class="p-4 md:p-6">
      {#if loading}
        <div class="rounded-2xl bg-white p-6 shadow-md">
          <p class="text-[#9c7b7b]">Loading schedule...</p>
        </div>
      {:else if error}
        <div class="rounded-2xl bg-white p-6 shadow-md">
          <p class="text-red-500">{error}</p>
        </div>
      {:else}
        <div class="space-y-6">
          <div class="rounded-3xl bg-white p-6 shadow-md md:hidden">
            <p class="mb-3 text-sm font-medium text-[#6b4f4f]">Choose a view</p>
            <div class="flex gap-2">
              <button
                type="button"
                onclick={() => (view = 'day')}
                class={`flex-1 rounded-lg px-4 py-2 ${
                  view === 'day'
                    ? 'bg-[#ff2d96] text-white'
                    : 'bg-[#f7edee] text-[#6b4f4f]'
                }`}
              >
                Day
              </button>

              <button
                type="button"
                onclick={() => (view = 'week')}
                class={`flex-1 rounded-lg px-4 py-2 ${
                  view === 'week'
                    ? 'bg-[#ff2d96] text-white'
                    : 'bg-[#f7edee] text-[#6b4f4f]'
                }`}
              >
                Week
              </button>

              <button
                type="button"
                onclick={() => (view = 'month')}
                class={`flex-1 rounded-lg px-4 py-2 ${
                  view === 'month'
                    ? 'bg-[#ff2d96] text-white'
                    : 'bg-[#f7edee] text-[#6b4f4f]'
                }`}
              >
                Month
              </button>
            </div>
          </div>

          <ScheduleCalendar shifts={filteredShifts} {view} />
        </div>
      {/if}
    </main>
  </div>
</div>