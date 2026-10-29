<script lang="ts">
  const days = [
    { short: 'Mon', date: '12' },
    { short: 'Tue', date: '13', highlight: true },
    { short: 'Wed', date: '14' },
    { short: 'Thu', date: '15' },
    { short: 'Fri', date: '16' }
  ];

  const rows = [
    [
      { time: '9a–12p', label: 'Wig Management', tone: 'pink' },
      null,
      { time: '10a–12p', label: 'Inventory', tone: 'rose' },
      null,
      { time: '11a–12p', label: 'Sales Floor', tone: 'gold' }
    ],
    [
      null,
      { time: '12p–3p', label: 'Cleaning', tone: 'blush' },
      null,
      { time: '12p–3p', label: 'Restocking', tone: 'pink' },
      null
    ],
    [
      null,
      { time: '3p–6p', label: 'Store Organization', tone: 'pink' },
      null,
      { time: '3p–6p', label: 'Wig Management', tone: 'rose' },
      { time: '3p–6p', label: 'Sales Floor', tone: 'rose' }
    ],
    [
      { time: '6p–8p', label: 'Store Organization', tone: 'brown' },
      { time: '6p–8p', label: 'Inventory', tone: 'pink' },
      { time: '6p–8p', label: 'Cleaning', tone: 'rose' },
      { time: '6p–8p', label: 'Restocking', tone: 'gold' },
      { time: '6p–8p', label: 'Sales Floor', tone: 'blush' }
    ]
  ];

  const rowLabels = [
    { time: '9 AM', range: '9–12' },
    { time: '12 PM', range: '12–3' },
    { time: '3 PM', range: '3–6' },
    { time: '6 PM', range: '6–8' }
  ];

  const toneClasses: Record<string, string> = {
    pink: 'bg-linear-to-r from-[#ff5ca8] to-[#ff8f84] text-white',
    rose: 'bg-[#f6d7df] text-[#744d54]',
    blush: 'bg-[#fdeef3] text-[#875f67]',
    gold: 'bg-[#f5e8cf] text-[#7a6143]',
    brown: 'bg-[#8f6a62] text-white'
  };
</script>

<div class="relative mx-auto w-full max-w-215 pt-10 lg:pt-12">
  <div class="pointer-events-none absolute -left-10 top-8 h-32 w-32 rounded-full bg-[#ffd7e5]/70 blur-3xl"></div>
  <div class="pointer-events-none absolute right-0 top-0 h-36 w-36 rounded-full bg-[#ffe9d7]/60 blur-3xl"></div>
  <div class="pointer-events-none absolute bottom-10 left-1/3 h-28 w-28 rounded-full bg-[#f8dbe3]/60 blur-3xl"></div>

  <div class="absolute left-3 top-0 z-15 hidden rounded-2xl border border-white/70 bg-white/90 px-4 py-3 shadow-[0_14px_40px_rgba(161,117,127,0.18)] backdrop-blur animate-float-soft lg:block">
    <p class="text-[0.65rem] uppercase tracking-[0.28em] text-[#b08a92]">Scheduled Days</p>
    <p class="mt-1 text-sm font-semibold text-[#6f5255]">Working 5 Days This Week</p>
  </div>

  <div class="absolute -bottom-6 -right-4 z-20 hidden rounded-2xl border border-white/70 bg-white/90 px-4 py-3 shadow-[0_14px_40px_rgba(161,117,127,0.18)] backdrop-blur animate-float-soft-delayed lg:block">
    <p class="text-[0.65rem] uppercase tracking-[0.28em] text-[#b08a92]">Team Size</p>
    <p class="mt-1 text-sm font-semibold text-[#6f5255]">10 people max</p>
  </div>

  <div class="absolute right-4 top-2 z-20 hidden rounded-full border border-white/70 bg-[#ff5ca8] px-4 py-2 text-xs font-semibold text-white shadow-[0_12px_30px_rgba(255,92,168,0.28)] animate-drift lg:block">
    Schedule synced
  </div>

  <div class="relative overflow-hidden rounded-[2.2rem] border border-white/70 bg-white/70 shadow-[0_28px_80px_rgba(161,117,127,0.16)] backdrop-blur-xl">
    <div class="pointer-events-none absolute inset-y-0 -left-1/3 z-10 w-1/3 bg-linear-to-r from-transparent via-white/30 to-transparent blur-xl animate-shimmer"></div>

    <div class="border-b border-[#eedce2] bg-[linear-gradient(180deg,rgba(255,255,255,0.88),rgba(255,247,249,0.7))] px-4 py-4 md:px-6">
      <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div>
          <p class="text-[0.72rem] font-semibold uppercase tracking-[0.32em] text-[#b28b93]">
            Unique Beauty Team
          </p>
          <div class="mt-2 flex flex-wrap items-center gap-3">
            <h3 class="text-2xl font-semibold tracking-[-0.03em] text-[#6d4d52] md:text-3xl">
              Week at a glance
            </h3>
            <span class="rounded-full bg-[#fff1f6] px-3 py-1 text-xs font-semibold text-[#ff4f9d] animate-pulse-soft">
              Live planning
            </span>
          </div>
        </div>

        <div class="flex flex-wrap items-center gap-2">
          <button class="rounded-xl border border-[#ecdde1] bg-white px-3 py-2 text-sm font-medium text-[#8b6d73] shadow-sm">
            Calendar view
          </button>
          <button class="rounded-xl border border-[#ecdde1] bg-white px-3 py-2 text-sm font-medium text-[#8b6d73] shadow-sm">
            Jul 12–16
          </button>
        </div>
      </div>
    </div>

    <div class="overflow-x-auto">
      <div class="grid min-w-170 grid-cols-[76px_repeat(5,minmax(120px,1fr))]">
        <div class="border-b border-r border-[#f0e1e6] bg-[#fffafb] px-2 py-4 text-center">
          <span class="text-[0.6rem] font-semibold uppercase tracking-[0.18em] text-[#b18b93]">Time</span>
        </div>
        {#each days as day (day.short)}
          <div
            class={`border-b border-r border-[#f0e1e6] px-3 py-4 text-center sm:px-4 ${day.highlight ? 'bg-[#fff5f8]' : 'bg-[linear-gradient(180deg,#fff,#fffafb)]'}`}
          >
            <p class="text-[0.65rem] font-semibold uppercase tracking-[0.22em] text-[#b18b93] sm:text-xs">{day.short}</p>
            <p class={`mt-1 text-base font-semibold sm:text-lg ${day.highlight ? 'text-[#ff4f9d]' : 'text-[#6d4d52]'}`}>
              {day.date}
            </p>
          </div>
        {/each}

        {#each rows as row, rowIndex (rowIndex)}
          <div class="flex min-h-26.5 items-center justify-center border-r border-t border-[#f0e1e6] bg-[#fffafb] px-2 text-center">
            <div class="space-y-1 text-center">
              <span class="block whitespace-nowrap text-[0.72rem] font-semibold uppercase tracking-[0.08em] text-[#8f7278]">
                {rowLabels[rowIndex].time}
              </span>
              <span class="block whitespace-nowrap text-[0.62rem] font-medium tracking-[0.08em] text-[#c09ca5]">
                {rowLabels[rowIndex].range}
              </span>
            </div>
          </div>
          {#each row as cell, dayIndex (dayIndex)}
            <div class={`relative min-h-26.5 border-r border-t border-[#f0e1e6] p-2 sm:p-3 ${days[dayIndex].highlight ? 'bg-[#fffafb]' : 'bg-white/70'}`}>
            {#if cell}
              <div
                class={`relative rounded-[1.2rem] px-3 py-3 shadow-[0_10px_22px_rgba(161,117,127,0.10)] ring-1 ring-white/40 transition-transform duration-500 hover:scale-[1.02] animate-breathe ${toneClasses[cell.tone]}`}
                style={`animation-delay:${rowIndex * 0.35 + dayIndex * 0.12}s`}
              >
                <div class="flex items-start justify-between gap-2">
                  <div>
                    <p class="text-sm font-semibold">{cell.time}</p>
                    <p class="mt-1 text-[10px] font-medium uppercase leading-4 tracking-[0.12em] opacity-80">
                      {cell.label}
                    </p>
                  </div>

                  <span class="h-2.5 w-2.5 rounded-full bg-white/80 animate-dot"></span>
                </div>
              </div>
            {:else}
              <div class="absolute inset-3 rounded-2xl border border-dashed border-[#f4e6ea]"></div>
            {/if}
          </div>
        {/each}
      {/each}
      </div>
    </div>

    <div class="border-t border-[#eedce2] bg-[linear-gradient(180deg,#fffafc,#fff5f8)] px-4 py-4 md:px-6">
      <div class="flex flex-wrap items-center gap-3 text-sm text-[#8f7278]">
        <span class="rounded-full border border-[#efdce3] bg-white px-3 py-2">Weekly view</span>
        <span class="rounded-full border border-[#efdce3] bg-white px-3 py-2">Time-off tracking</span>
        <span class="rounded-full border border-[#efdce3] bg-white px-3 py-2">Shift coverage clarity</span>
      </div>
    </div>
  </div>
</div>

<style>
  @keyframes shimmer {
    0% {
      transform: translateX(-20%);
      opacity: 0;
    }
    20% {
      opacity: 0.55;
    }
    50% {
      opacity: 0.35;
    }
    100% {
      transform: translateX(420%);
      opacity: 0;
    }
  }

  @keyframes floatSoft {
    0%, 100% {
      transform: translateY(0px);
    }
    50% {
      transform: translateY(-8px);
    }
  }

  @keyframes drift {
    0%, 100% {
      transform: translate3d(0, 0, 0);
    }
    50% {
      transform: translate3d(0, -6px, 0);
    }
  }

  @keyframes breathe {
    0%, 100% {
      transform: scale(1);
    }
    50% {
      transform: scale(1.015);
    }
  }

  @keyframes pulseSoft {
    0%, 100% {
      box-shadow: 0 0 0 0 rgba(255, 79, 157, 0.10);
      opacity: 1;
    }
    50% {
      box-shadow: 0 0 0 8px rgba(255, 79, 157, 0.03);
      opacity: 0.95;
    }
  }

  @keyframes dotPulse {
    0%, 100% {
      transform: scale(1);
      opacity: 0.85;
    }
    50% {
      transform: scale(1.25);
      opacity: 1;
    }
  }

  :global(.animate-shimmer) {
    animation: shimmer 7s ease-in-out infinite;
  }

  :global(.animate-float-soft) {
    animation: floatSoft 5s ease-in-out infinite;
  }

  :global(.animate-float-soft-delayed) {
    animation: floatSoft 5.8s ease-in-out infinite;
  }

  :global(.animate-drift) {
    animation: drift 4.8s ease-in-out infinite;
  }

  :global(.animate-breathe) {
    animation: breathe 4.6s ease-in-out infinite;
  }

  :global(.animate-pulse-soft) {
    animation: pulseSoft 3.6s ease-in-out infinite;
  }

  :global(.animate-dot) {
    animation: dotPulse 2.8s ease-in-out infinite;
  }
</style>