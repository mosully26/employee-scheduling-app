<script lang="ts">
  import { resolve } from '$app/paths';

  const capabilities = [
    { number: '01', title: 'Unified scheduling', text: 'Give every team member a precise view of upcoming shifts, locations, roles, and coverage.' },
    { number: '02', title: 'Time-off workflow', text: 'Submit requests, monitor approvals, and keep managers ahead of staffing changes.' },
    { number: '03', title: 'Team communications', text: 'Share company announcements and daily priorities from one organized workspace.' }
  ];

  const metrics = [
    { value: 'One', label: 'shared workspace' },
    { value: 'Live', label: 'schedule visibility' },
    { value: '24/7', label: 'team access' }
  ];

  const previewDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const previewShifts = [
    { day: 0, name: 'Mia', role: 'Store Lead', time: '9–3', storeHours: 'Store hours 9–8', tone: 'bg-[#342b2b] text-white' },
    { day: 1, name: 'Jasmine', role: 'Sales Floor', time: '10–4', storeHours: 'Store hours 9–8', tone: 'bg-[#fff0f7] text-[#b52b69]' },
    { day: 2, name: 'Ashley', role: 'Wig Styling', time: '11–5', storeHours: 'Store hours 9–8', tone: 'bg-[#f4ead6] text-[#80602f]' },
    { day: 3, name: 'Nia', role: 'Inventory', time: '9–3', storeHours: 'Store hours 9–8', tone: 'bg-[#fde7ef] text-[#a52a63]' },
    { day: 4, name: 'Team', role: 'Store Coverage', time: '10–6', storeHours: 'Store hours 9–8', tone: 'bg-[#342b2b] text-white' },
    { day: 5, name: 'Kendra', role: 'Weekend Lead', time: '11–7', storeHours: 'Store hours 9–8', tone: 'bg-[#d93483] text-white' },
    { day: 6, name: 'Jordan', role: 'Sunday Coverage', time: '12–5', storeHours: 'Store hours 9–5', tone: 'bg-[#eee8e8] text-[#756565]' }
  ];

  let selectedDay = $state(2);
</script>

<svelte:head>
  <title>Unique Beauty | Employee Scheduling Platform</title>

  <meta
    name="description"
    content="A custom-built employee scheduling and workforce management platform for Unique Beauty, designed to simplify scheduling, coordinate team members, manage staffing requests, and improve daily operations."
  />

  <meta property="og:type" content="website" />

  <meta
    property="og:title"
    content="Unique Beauty | Employee Scheduling Platform"
  />

  <meta
    property="og:description"
    content="Explore a custom-built employee scheduling and workforce management platform developed for Unique Beauty using SvelteKit, Supabase, and PostgreSQL. Built to simplify scheduling and improve team coordination."
  />

  <meta
    property="og:image"
    content="https://ubteam.vercel.app/linkedin-preview.png"
  />

  <meta
    property="og:image:width"
    content="1200"
  />

  <meta
    property="og:image:height"
    content="630"
  />

  <meta
    property="og:url"
    content="https://ubteam.vercel.app/"
  />

  <meta name="twitter:card" content="summary_large_image" />
</svelte:head>

<div class="min-h-screen overflow-hidden bg-[#f7f2f0] text-[#342b2b]">
  <div class="pointer-events-none fixed inset-x-0 top-0 h-130 bg-[radial-gradient(circle_at_78%_20%,rgba(255,45,150,0.16),transparent_31%),radial-gradient(circle_at_20%_10%,rgba(212,161,58,0.12),transparent_28%)]"></div>

  <div class="relative mx-auto max-w-360 px-5 sm:px-8 lg:px-12">
    <header class="flex items-center justify-between py-5 md:py-7">
      <a href={resolve('/')} class="flex items-center gap-3" aria-label="Unique Beauty home">
        <img src="/favicon.png" alt="" class="h-16 w-16 object-contain sm:h-20 sm:w-20" />
        <div>
          <p class="text-2xl font-bold tracking-tight text-[#342b2b] sm:text-2xl">Unique Beauty</p>
          <p class="text-xs font-semibold uppercase tracking-[0.28em] text-[#a16f7c] sm:text-sm">Team Operations</p>
        </div>
      </a>

      <nav class="flex items-center gap-2" aria-label="Account navigation">
        <a href={resolve('/login')} class="rounded-full px-4 py-2.5 text-sm font-semibold text-[#584849] transition hover:bg-white/70 sm:px-5">Sign in</a>
        <a href={resolve('/signup')} class="rounded-full bg-[#342b2b] px-4 py-2.5 text-sm font-semibold text-white shadow-[0_10px_30px_rgba(52,43,43,0.18)] transition hover:-translate-y-0.5 hover:bg-[#1f1919] sm:px-5">Create account</a>
      </nav>
    </header>

    <main>
      <section class="grid items-center gap-12 pb-16 pt-10 lg:grid-cols-[1.02fr_0.98fr] lg:pb-24 lg:pt-16">
        <div>
          <div class="mb-7 inline-flex items-center gap-2 rounded-full border border-[#e1d4d2] bg-white/70 px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-[#9a6975] backdrop-blur">
            <span class="h-2 w-2 rounded-full bg-[#ff2d96] shadow-[0_0_0_4px_rgba(255,45,150,0.12)]"></span>
            Workforce platform
          </div>

          <h1 class="max-w-3xl text-5xl font-bold leading-[0.96] tracking-[-0.055em] text-[#342b2b] sm:text-6xl lg:text-[5.25rem]">
            Work Beautifully<br />
            <span class="text-[#d93483]">Stay In Sync</span>
          </h1>

          <p class="mt-7 max-w-xl text-lg leading-8 text-[#756565]">
            The central operating workspace for Unique Beauty teams—bringing schedules, staffing requests, and important updates into one clear experience.
          </p>

          <div class="mt-9 flex flex-col gap-3 sm:flex-row">
            <a href={resolve('/dashboard')} class="inline-flex items-center justify-center rounded-full bg-[#d93483] px-7 py-4 text-sm font-bold text-white shadow-[0_18px_40px_rgba(217,52,131,0.28)] transition hover:-translate-y-1 hover:bg-[#c42670]">
              Open dashboard
            </a>
            <a href={resolve('/schedule')} class="inline-flex items-center justify-center rounded-full border border-[#d9cbca] bg-white/80 px-7 py-4 text-sm font-bold text-[#584849] transition hover:-translate-y-1 hover:bg-white">
              Explore schedule
            </a>
          </div>

          <div class="mt-12 grid max-w-xl grid-cols-3 border-y border-[#ded2d0] py-5">
            {#each metrics as metric (metric.label)}
              <div class="border-r border-[#ded2d0] px-3 first:pl-0 last:border-r-0">
                <p class="text-xl font-bold text-[#342b2b]">{metric.value}</p>
                <p class="mt-1 text-[10px] font-bold uppercase tracking-[0.13em] text-[#9d8585]">{metric.label}</p>
              </div>
            {/each}
          </div>
        </div>

        <div class="relative lg:pl-4">
          <div class="absolute -inset-6 -z-10 rounded-4xl bg-linear-to-br from-[#ffd8e8] to-[#f3e5c8] blur-2xl opacity-70"></div>
          <div class="overflow-hidden rounded-4xl border border-white bg-white p-2 shadow-[0_35px_90px_rgba(70,48,51,0.22)]">
            <div class="rounded-3xl bg-[#fffafa] p-4 sm:p-5">
              <div class="flex items-center justify-between border-b border-[#eadfe0] pb-4">
                <div>
                  <p class="text-[10px] font-bold uppercase tracking-[0.22em] text-[#d93483]">Team schedule</p>
                  <p class="mt-1 text-lg font-bold text-[#342b2b]">October 26–November 1</p>
                </div>
                <div class="flex items-center gap-2">
                  <button type="button" class="flex h-8 w-8 items-center justify-center rounded-full bg-white text-sm font-bold text-[#756565] shadow-sm transition hover:bg-[#fff0f7]" aria-label="Previous week">‹</button>
                  <div class="flex items-center gap-2 rounded-full bg-white px-3 py-2 text-xs font-semibold text-[#756565] shadow-sm">
                    <span class="h-2 w-2 animate-pulse rounded-full bg-[#3bb273]"></span> Live
                  </div>
                  <button type="button" class="flex h-8 w-8 items-center justify-center rounded-full bg-[#342b2b] text-sm font-bold text-white shadow-sm transition hover:bg-[#d93483]" aria-label="Next week">›</button>
                </div>
              </div>

              <div class="mt-4 overflow-x-auto pb-1">
                <div class="grid min-w-105 grid-cols-7 gap-1.5">
                {#each previewDays as day, index (day)}
                  <button
                    type="button"
                    onclick={() => (selectedDay = index)}
                    class={`relative min-w-0 rounded-xl px-1 py-2 text-center transition-all duration-300 ${selectedDay === index ? 'bg-[#342b2b] text-white shadow-lg' : 'text-[#342b2b] hover:bg-white'}`}
                  >
                    <p class={`text-[9px] font-bold uppercase tracking-[0.12em] ${selectedDay === index ? 'text-white/70' : 'text-[#9d8585]'}`}>{day}</p>
                    <p class="mt-1 text-base font-bold">{index === 6 ? 1 : 26 + index}</p>
                    {#if selectedDay === index}<span class="absolute -bottom-1 left-1/2 h-1.5 w-1.5 -translate-x-1/2 rounded-full bg-[#ff2d96]"></span>{/if}
                  </button>
                {/each}
                </div>
              </div>

              <div class="mt-4 overflow-x-auto pb-2">
                <div class="grid min-w-145 grid-cols-7 gap-2">
                {#each previewDays as day, index (day)}
                  <button
                    type="button"
                    onclick={() => (selectedDay = index)}
                    class={`group flex min-h-44 flex-col rounded-2xl p-3 text-left transition-all duration-300 hover:-translate-y-1 hover:shadow-xl ${previewShifts[index].tone} ${selectedDay === index ? 'ring-2 ring-[#ff2d96] ring-offset-2 ring-offset-[#fffafa]' : 'opacity-95 hover:opacity-100'}`}
                  >
                    <span class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-white/25 text-[11px] font-bold">{previewShifts[index].name.slice(0, 1)}</span>
                    <p class="mt-3 text-xs font-bold">{previewShifts[index].name}</p>
                    <p class="mt-2 min-h-12 text-[10px] font-bold uppercase leading-4 tracking-[0.03em] opacity-90">{previewShifts[index].role}</p>
                    <p class="mt-auto text-[11px] font-bold opacity-100">{previewShifts[index].time}</p>
                    <p class="mt-1 text-[9px] font-bold uppercase leading-4 tracking-[0.02em] opacity-80">{previewShifts[index].storeHours}</p>
                  </button>
                {/each}
                </div>
              </div>

              <div class="mt-4 flex items-center justify-between gap-3 rounded-2xl border border-[#f0e4e6] bg-white px-4 py-3">
                <div>
                  <p class="text-[10px] font-bold uppercase tracking-[0.14em] text-[#b08e95]">{previewDays[selectedDay]} • {selectedDay === 6 ? 'November 1' : `October ${26 + selectedDay}`}</p>
                  <p class="mt-1 text-sm font-bold text-[#342b2b]">{previewShifts[selectedDay].name} · {previewShifts[selectedDay].role}</p>
                </div>
                <span class="rounded-full bg-[#eaf7f1] px-3 py-1.5 text-xs font-bold text-[#278b60]">✓ Covered</span>
              </div>
            </div>
          </div>
          <div class="absolute -bottom-14 -right-3 rounded-2xl border border-white/80 bg-white/90 px-5 py-4 shadow-xl backdrop-blur sm:-right-7">
            <div class="flex items-center gap-3">
              <span class="flex h-9 w-9 items-center justify-center rounded-full bg-[#fff0f7] text-[#d93483]">✓</span>
              <div><p class="text-sm font-bold">Schedule connected</p><p class="text-xs text-[#907878]">Team updates in real time</p></div>
            </div>
          </div>
        </div>
      </section>

      <section class="border-t border-[#ded2d0] py-16 lg:py-24">
        <div class="mb-10 flex flex-col justify-between gap-5 md:flex-row md:items-end">
          <div>
            <div class="mb-5 flex items-center gap-3">
              <span class="h-px w-10 bg-[#d93483]"></span>
              <p class="text-xs font-bold uppercase tracking-[0.22em] text-[#d93483]">Built for daily operations</p>
            </div>
            <h2 class="mt-3 max-w-xl text-4xl font-bold tracking-[-0.04em] text-[#342b2b] md:text-5xl">Everything your team needs, finally in one place.</h2>
          </div>
          <p class="max-w-md text-base leading-7 text-[#756565]">A focused experience designed to reduce scheduling friction and keep everyone confidently aligned.</p>
        </div>

        <div class="grid gap-4 md:grid-cols-3">
          {#each capabilities as capability (capability.number)}
            <article class="group relative min-h-72 overflow-hidden rounded-4xl border border-white/80 bg-white p-7 shadow-[0_18px_50px_rgba(75,55,57,0.08)] transition duration-500 hover:-translate-y-2 hover:border-[#f0bfd4] hover:shadow-[0_28px_70px_rgba(75,55,57,0.16)]">
              <div class="pointer-events-none absolute -right-16 -top-16 h-44 w-44 rounded-full bg-[#fff1f7] transition-transform duration-500 group-hover:scale-125"></div>
              <div class="relative flex items-center justify-between">
                <span class="flex h-11 w-11 items-center justify-center rounded-full border border-[#f0d6df] bg-[#fff9fb] text-sm font-bold text-[#d93483]">{capability.number}</span>
                <span class="h-px w-14 bg-[#e0d5d3] transition-all duration-500 group-hover:w-24 group-hover:bg-[#d93483]"></span>
              </div>
              <div class="relative mt-12">
                <p class="mb-3 text-[10px] font-bold uppercase tracking-[0.22em] text-[#b08e95]">Unique Beauty platform</p>
                <h3 class="text-2xl font-bold tracking-tight text-[#342b2b]">{capability.title}</h3>
                <p class="mt-4 leading-7 text-[#756565]">{capability.text}</p>
              </div>
              <div class="absolute bottom-7 right-7 flex h-9 w-9 items-center justify-center rounded-full bg-[#342b2b] text-white opacity-0 transition-all duration-300 group-hover:translate-x-0 group-hover:opacity-100 translate-x-2" aria-hidden="true">→</div>
            </article>
          {/each}
        </div>
      </section>

      <section class="mb-12 rounded-4xl bg-[#342b2b] px-6 py-10 text-white md:px-10 md:py-12">
        <div class="flex flex-col items-start justify-between gap-7 md:flex-row md:items-center">
          <div>
            <p class="text-xs font-bold uppercase tracking-[0.22em] text-[#e8b3cb]">Ready when your team is</p>
            <h2 class="mt-3 text-3xl font-bold tracking-tight md:text-4xl">Make every shift feel organized.</h2>
          </div>
          <a href={resolve('/signup')} class="rounded-full bg-white px-6 py-3.5 text-sm font-bold text-[#342b2b] transition hover:-translate-y-1">Get started</a>
        </div>
      </section>
    </main>
  </div>
</div>