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
</script>

<svelte:head>
  <title>Unique Beauty | Team Scheduling</title>
  <meta name="description" content="A modern team scheduling and workforce management portal for Unique Beauty." />
</svelte:head>

<div class="min-h-screen overflow-hidden bg-[#f7f2f0] text-[#342b2b]">
  <div class="pointer-events-none fixed inset-x-0 top-0 h-130 bg-[radial-gradient(circle_at_78%_20%,rgba(255,45,150,0.16),transparent_31%),radial-gradient(circle_at_20%_10%,rgba(212,161,58,0.12),transparent_28%)]"></div>

  <div class="relative mx-auto max-w-360 px-5 sm:px-8 lg:px-12">
    <header class="flex items-center justify-between py-5 md:py-7">
      <a href={resolve('/')} class="flex items-center gap-3" aria-label="Unique Beauty home">
        <img src="/favicon.png" alt="" class="h-11 w-11 object-contain" />
        <div>
          <p class="text-lg font-bold tracking-tight text-[#342b2b]">Unique Beauty</p>
          <p class="text-[10px] font-semibold uppercase tracking-[0.28em] text-[#a16f7c]">Team Operations</p>
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
            Work beautifully.<br />
            <span class="text-[#d93483]">Stay in sync.</span>
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
            <div class="relative overflow-hidden rounded-3xl">
              <img src="/unique-beauty-storefront.png" alt="Unique Beauty store" class="aspect-5/4 w-full object-cover" />
              <div class="absolute inset-x-0 bottom-0 bg-linear-to-t from-[#211919]/80 via-transparent to-transparent p-6 pt-24 text-white">
                <p class="text-xs font-bold uppercase tracking-[0.22em] text-white/70">Unique Beauty</p>
                <p class="mt-2 text-2xl font-bold">One team. One direction.</p>
              </div>
            </div>
          </div>
          <div class="absolute -bottom-5 -left-3 rounded-2xl border border-white/80 bg-white/90 px-5 py-4 shadow-xl backdrop-blur sm:-left-7">
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
            <p class="text-xs font-bold uppercase tracking-[0.22em] text-[#d93483]">Built for daily operations</p>
            <h2 class="mt-3 max-w-xl text-4xl font-bold tracking-[-0.04em] text-[#342b2b] md:text-5xl">Everything your team needs, finally in one place.</h2>
          </div>
          <p class="max-w-md text-base leading-7 text-[#756565]">A focused experience designed to reduce scheduling friction and keep everyone confidently aligned.</p>
        </div>

        <div class="grid gap-4 md:grid-cols-3">
          {#each capabilities as capability (capability.number)}
            <article class="group rounded-[1.75rem] border border-[#e6dbd9] bg-white p-7 shadow-[0_14px_40px_rgba(75,55,57,0.06)] transition duration-300 hover:-translate-y-2 hover:shadow-[0_24px_55px_rgba(75,55,57,0.12)]">
              <div class="flex items-center justify-between">
                <span class="text-sm font-bold text-[#d93483]">{capability.number}</span>
                <span class="h-px w-16 bg-[#e0d5d3] transition-all group-hover:w-24 group-hover:bg-[#d93483]"></span>
              </div>
              <h3 class="mt-16 text-xl font-bold text-[#342b2b]">{capability.title}</h3>
              <p class="mt-3 leading-7 text-[#756565]">{capability.text}</p>
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