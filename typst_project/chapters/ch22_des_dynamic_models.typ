#import "../common.typ": *

= Chapter 22. Discrete Event Simulation and Dynamic Models

Chapter 21 closed with a specific transition: microsimulation gives each patient their own history and heterogeneity, but every simulated patient still walks through the model entirely independently of every other patient. This chapter drops that last assumption. Discrete event simulation (DES) lets simulated individuals compete for shared, finite resources -- queue for a nurse, wait for a bed -- and dynamic transmission models let one person's disease status change another person's risk of disease. Both are "interacting individuals" model families; this chapter builds the first with `simmer`, the second with `deSolve` and `EpiModel`, and closes by giving you a decision framework for choosing among all four model families introduced across Chapters 19-22.

#learning-objectives((
  [Explain DES's core concepts -- events, the event queue, resources and their capacity, attributes, and trajectories -- and why they let simulated individuals interact in ways microsimulation cannot (22.1).],
  [Build a working discrete event simulation in R using the `simmer` package, including a worked single-resource queueing model (22.2).],
  [Represent competing next-events and time-to-event racing mechanics inside a DES trajectory, and recognise where `simmer`'s API needs a manual workaround (22.3).],
  [Build compartmental (SIR/SEIR) infectious-disease transmission models with `deSolve::ode()`, and relate agent-based/network alternatives via `EpiModel` (22.4).],
  [Link a transmission model's outputs to a cost-effectiveness analysis, and name the specific methodological risk of using a static model for an infectious-disease intervention (22.4).],
  [Choose between Markov cohort, microsimulation, DES, and dynamic transmission model structures for a given HEOR/HTA question (22.5).],
  [Work a complete, independently-checked worked example of a TB screening/preventive-therapy intervention using a compartmental transmission model (22.6).],
))

== 22.1 Concepts: events, queues, resources and attributes

Chapter 21 built microsimulation models where every patient walked their own corridor, alone. Each patient's transitions depended only on their own history and random draws; run patient 1047 twice and nothing patient 2 or patient 3003 does will ever touch it. That independence is what made Chapter 21's models fast to reason about — and it is also precisely what breaks the moment two patients need the *same nurse*, the *same hospital bed*, or the *same infectious contact*. A microsimulation cannot represent a queue, because a queue is defined by one patient having to wait for another patient to finish using something scarce. It cannot represent an epidemic, because an epidemic is defined by one patient's infectiousness changing another patient's risk.

Discrete Event Simulation (DES) exists to drop that independence assumption. In a DES model, simulated individuals *interact*: they compete for shared, finite resources, they queue behind each other, and — in the dynamic transmission models of later chapters — they infect each other. This is the single reason DES is worth learning as a distinct technique rather than just "microsimulation with extra code": it is the first model family in this book where the population, not just the individual, is the unit that matters.

#difficult-terminology("Entity (or arrival)", [
  An *entity* — `simmer`'s documentation calls it an *arrival* — is one simulated individual moving through the model: one patient, one specimen, one ambulance. Unlike a microsimulation "patient" who exists in isolation, a DES entity can be made to wait behind other entities and to be served by the same finite pool of staff or equipment that they are also competing for.
])

Think of a single-nurse TB-screening clinic. Patients arrive one after another, not at fixed intervals but at random moments — some gaps are short, some long. There is one nurse. If the nurse is free when a patient arrives, screening starts immediately. If the nurse is busy with an earlier patient, the new arrival joins the queue and waits. Once screening finishes, the nurse becomes free and the next patient in line is pulled off the queue. This is the entire mechanical skeleton of DES, and essentially everything in this chapter is a variation on it.

A DES engine advances time not in fixed steps (as a Markov cohort model does, one annual cycle at a time) but by jumping from event to event: "patient 14 arrives," "the nurse finishes with patient 11," "patient 9 gives up and leaves the queue." Between events, nothing in the model changes, so there is no point computing anything — the simulation clock simply fast-forwards to the next scheduled event.

#difficult-terminology("Event queue", [
  The *event queue* is not the patients' waiting line — it is the simulation engine's internal to-do list, ordered by time: "at t=4.2, patient 14 arrives," "at t=5.0, the nurse finishes with patient 11," and so on. The engine always executes whichever event is earliest, then recomputes what new events that triggers (an arrival event may schedule a "start service" event; a "finish service" event may schedule the next patient's "start service"). You never manipulate this queue directly in `simmer` — it is managed for you — but understanding that it exists explains why DES output is driven by *when* things happen, not by a fixed clock tick.
])

#difficult-terminology("Resource and its capacity", [
  A *resource* in DES is anything finite that entities compete to use: a nurse, an X-ray machine, a hospital bed, a batch of GeneXpert cartridges. Its *capacity* is how many entities it can serve simultaneously — one nurse has capacity 1; a two-bed isolation ward has capacity 2. When all capacity is in use, arriving entities wait in that resource's queue (which may itself have a finite size, or be unlimited). Resource capacity is where DES earns its keep for HEOR: it is how you model the throughput limits — nurse-hours, scanner-hours, bed-days — that a microsimulation simply cannot see.
])

#difficult-terminology("Attribute", [
  An *attribute* is a piece of data an entity carries with it as it moves through the model — equivalent to a patient-level covariate in microsimulation. A patient's attribute might be `smear_positive = 1`, `age = 34`, or `priority = 2`. Attributes let later events and routing decisions depend on what happened earlier to *that specific* entity, exactly as individual state did in Chapter 21 — DES keeps this feature, it just adds interaction on top of it.
])

#difficult-terminology("Trajectory", [
  A *trajectory* is the template path an entity follows: arrive → queue for nurse → be screened → (maybe) queue for X-ray → leave. In `simmer`, you build this once as an R object and then every arriving patient is sent down a copy of it. It is the DES equivalent of the "state-transition diagram" from Chapter 20, except steps are tied to *resources and durations* rather than to annual transition probabilities.
])

#pitfall([
  It is tempting to treat "DES" and "agent-based model" as synonyms because both simulate individuals explicitly. They are not the same tool. A DES model's defining structure is entities queueing for *finite resources* along a *trajectory* with an *event queue* driving the clock — think operations/capacity questions ("how many nurses do we need to keep TB-screening wait times under 20 minutes?"). Dynamic transmission models (§22.4) reuse the DES engine but structure the interaction around *infectious contact between individuals* rather than *resource contention* — think epidemic/transmission questions. §22.1-22.3 are squarely about the operations-and-queueing use of DES; the same `simmer`-style machinery resurfaces in §22.4 wearing a transmission hat.
])

#agency-note([
  DES's use in HTA, not just hospital operations research, is the subject of its own named ISPOR-SMDM guidance document: Karnon J, Stahl JE, Brennan A, Caro JJ, Mar J, Möller J. "Modeling Using Discrete Event Simulation: A Report of the ISPOR-SMDM Modeling Good Research Practices Task Force-4." _Value in Health_ 2012;15(5):821-827. It walks through five stages a DES submitted to a reimbursement body should document — structural development, parameter estimation, model implementation, model analysis, and representation/reporting — and explicitly extends the *events*, *entities*, and *resource interaction* vocabulary introduced in this section into formal best-practice recommendations for each stage, rather than treating DES as merely a simulation-engineering choice with no HTA-specific reporting expectations of its own.
])

== 22.2 DES with `simmer`

`simmer` (Ucar & Smeets) is the standard R package for process-oriented DES. Its central idea is exactly the *trajectory* concept introduced above: you describe the path an entity follows using a small, chainable set of activities — `seize()` a resource, `timeout()` for a duration, `release()` it again — and then attach generators that create new entities over time and send them down that trajectory. simmer builds and advances the event queue for you; you never touch it directly.

The core building blocks, all verified against the current `simmer` CRAN documentation (v4.4.x):

- `trajectory(name)` — starts a new trajectory object that activities are piped into with `%>%`.
- `seize(.trj, resource, amount = 1, ...)` / `release(.trj, resource, amount = 1, ...)` — claim and give back units of a named resource.
- `timeout(.trj, task)` — advances the entity's clock by a fixed number or by the result of a function (e.g. a random draw), without consuming a resource.
- `add_resource(.env, name, capacity, queue_size = Inf, ...)` — defines a resource and how many entities it can serve at once, and how long its queue may grow.
- `add_generator(.env, name_prefix, trajectory, distribution, ...)` — creates new entities over time; `distribution` is a function returning successive inter-arrival times (e.g. `function() rexp(1, rate)`).
- `run(.env, until)` — executes the simulation up to a stopping time.
- `get_mon_arrivals(.env)` / `get_mon_resources(.env)` — pull the recorded per-entity and per-resource logs back out as data frames once the run finishes.

A minimal single-nurse TB-screening clinic, modelled as a classic M/M/1 queue — patients arrive at random (exponential inter-arrival times) and are screened for a random duration (exponential service time) by one nurse:

```r
library(simmer)
set.seed(2024)

# average inter-arrival time = 10 minutes -> arrival rate lambda = 1/10
# average screening time     =  8 minutes -> service rate  mu    = 1/8

patient <- trajectory("TB screening") %>%
  seize("nurse", amount = 1) %>%
  timeout(function() rexp(1, rate = 1 / 8)) %>%
  release("nurse", amount = 1)

clinic <- simmer("tb_clinic") %>%
  add_resource("nurse", capacity = 1, queue_size = Inf) %>%
  add_generator("patient", patient, function() rexp(1, rate = 1 / 10))

clinic %>% run(until = 8 * 60 * 20)   # simulate 20 clinic-days of 8 hours each

arrivals  <- get_mon_arrivals(clinic)
resources <- get_mon_resources(clinic)

arrivals$waiting_time <- arrivals$end_time - arrivals$start_time - arrivals$activity_time
mean(arrivals$waiting_time)   # average minutes spent queueing for the nurse
mean(resources$server)        # fraction of time the nurse resource is occupied
```

`get_mon_arrivals()` returns one row per entity with `start_time`, `end_time` and `activity_time` (time actually being served); subtracting gives queueing time per patient. `get_mon_resources()` logs every change of state in a resource (`server`, `queue`, `capacity`) with a timestamp, so you can reconstruct occupancy and queue length over the run.

#heor-practice([
  Before trusting any simulated wait-time number, sanity-check it against the closed-form queueing-theory benchmark for the simplified case, if one exists. For a stable M/M/1 queue with arrival rate $lambda$ and service rate $mu$ (utilisation $rho = lambda/mu < 1$), the expected steady-state wait *in queue* is $W_q = rho / (mu - lambda)$. With $lambda = 1/10$ and $mu = 1/8$ per minute, $rho = 0.8$ (the nurse is busy 80% of the time), and:

  $ W_q = 0.8 / (1/8 - 1/10) = 0.8 / 0.025 = 32 "minutes" $

  The average number of patients queueing is $L_q = rho^2/(1-rho) = 0.64/0.2 = 3.2$, and the average number anywhere in the system (queueing or being screened) is $L = lambda(W_q + 1/mu) = 0.1 times 40 = 4$ patients. A long enough `simmer` run of the model above should converge toward these numbers. If your simulated average wait is wildly different after a long run, suspect a coding error (wrong rate parameterisation is the single most common one — `rexp()` takes a *rate*, not a *mean*) before suspecting the theory.
])

#pitfall([
  `rexp(n, rate)` in R is parameterised by *rate*, not *mean inter-event time*. An average inter-arrival time of 10 minutes is `rate = 1/10`, not `rate = 10`. Swapping this by accident is the single most common `simmer` bug, and it silently produces a model that is either absurdly congested or absurdly empty rather than throwing an error — always sanity-check simulated utilisation ($rho = lambda/mu$, computable by hand from the parameters you intended) against what `get_mon_resources()` reports before interpreting any downstream wait-time result.
])

== 22.3 Competing events and time-to-event sampling

Chapter 10 introduced *competing risks*: a patient can experience exactly one of several possible next events (relapse, death, loss to follow-up), each with its own hazard, and whichever would happen soonest is the one that actually occurs. In a DES, this stops being a statistical abstraction and becomes the literal mechanics of the simulation clock: at any point an entity may have several *candidate* next events — "finish screening," "give up and leave the queue," "develop symptoms" — each governed by its own time-to-event distribution, and the engine must determine which fires first.

The cleanest way to operationalise "draw a time-to-event for each competing event, then let the smallest one win" in `simmer` is to do the racing yourself in R *before* handing a single number to `timeout()`, because `timeout()` only accepts one pre-resolved duration (or a function returning one) — it has no native "race these N clocks and take the minimum" primitive. This is a genuine gap in simmer's API relative to how the competing-risks literature is usually described, and it is worth being explicit about rather than implying `simmer` has a dedicated construct it does not:

```r
library(simmer)
set.seed(2024)

# three competing hazards for a screened patient, in events per day:
#   default clinical pathway completion : rate 1/14
#   loss to follow-up                   : rate 1/60
#   self-referral to another provider   : rate 1/90

sample_next_event <- function() {
  times <- c(
    complete = rexp(1, rate = 1 / 14),
    ltfu     = rexp(1, rate = 1 / 60),
    referral = rexp(1, rate = 1 / 90)
  )
  list(event = names(times)[which.min(times)], time = min(times))
}

env <- simmer("competing_pathway_sim")

race_result <- NULL   # closure-captured slot holding the single resolved race per entity

patient <- trajectory("competing pathway") %>%
  set_attribute("outcome_code", function() {
    # resolve the race exactly ONCE per entity and remember both pieces
    race_result <<- sample_next_event()
    c(complete = 1, ltfu = 2, referral = 3)[[race_result$event]]
  }) %>%
  timeout(function() race_result$time) %>%   # reuse the time already resolved above, no resampling
  branch(
    function() get_attribute(env, "outcome_code"),
    continue = c(TRUE, TRUE, TRUE),
    trajectory("completed")  %>% timeout(0),
    trajectory("ltfu")       %>% timeout(0),
    trajectory("referred")   %>% timeout(0)
  )
```

Here `env` is the `simmer()` environment object created a few lines above — `simmer`'s own documented pattern for reading an attribute inside a `branch()` option function is `get_attribute(env, "attribute_name")`, with `env` captured from the enclosing script by R's normal closure rules, not a special global-manager accessor. The race is resolved exactly once per entity (stored in `race_result` via `<<-`), and both the branch label and the `timeout()` duration reuse that single resolved draw rather than resampling the race a second time. This is one place where `simmer`'s clean "one trajectory, piped activities" style needs a small manual workaround to express something genuinely continuous-time (a race between hazards) rather than a native primitive — worth knowing before assuming every DES mechanic has a one-line `simmer` verb.

`branch(.trj, option, continue, ...)` is the verified, documented `simmer` primitive for *discrete* branching: `option` is a function returning an integer `1..N` selecting which of `N` supplied sub-trajectories to follow (or `0` to skip the branch entirely), and `continue` is a vector of booleans saying whether each branch rejoins the main trajectory afterwards. This is the right tool when the competing outcomes are genuinely categorical with fixed or attribute-dependent probabilities (e.g. "70% complete screening, 20% are lost to follow-up, 10% are referred elsewhere") rather than racing continuous-time clocks:

```r
patient_simple <- trajectory("simple triage") %>%
  branch(
    function() sample(1:3, 1, prob = c(0.7, 0.2, 0.1)),
    continue = c(TRUE, TRUE, TRUE),
    trajectory("screened")   %>% seize("nurse") %>% timeout(8) %>% release("nurse"),
    trajectory("ltfu")       %>% timeout(0),
    trajectory("referred")   %>% timeout(0)
  )
```

#agency-note([
  The exponential-race mechanics above (minimum of independent exponential competing hazards being itself exponential with the summed rate) is a standard, well-established probability result, not a `simmer`-specific feature — it is taught the same way in Chapter 10's competing-risks material. Flag it to a biostatistics-trained reviewer only if your competing events are *not* plausibly memoryless (e.g. hazards that change sharply with time since screening), in which case drawing from the correct time-varying hazard for each candidate event, not a fixed-rate exponential, matters more than how `simmer` wires the branching.
])

// OPEN ITEMS (for assembler review, not part of typeset text):
// - Verified live against r-simmer.org / CRAN docs: simmer(), trajectory(), seize()/release(), timeout(),
//   add_resource(), add_generator(), run(), get_mon_arrivals(), get_mon_resources(), branch(), set_attribute(), get_attribute().
//   Source pages: r-simmer.org/reference/branch.html, r-simmer.org/reference/seize.html,
//   CRAN "Bank Tutorial: Part I" vignette (simmer-04-bank-1.html), r-simmer.org homepage, simmer.pdf (CRAN manual TOC).
// - Fixed during assembly: the original draft called a non-existent simmer::get_global_mgr() inside the branch()
//   option function in 22.3's race example. Replaced with the documented get_attribute(env, "name") pattern, where
//   `env` is the simmer() object already in scope -- this is standard R closure behaviour, not a simmer-specific trick.
// - Numeric claims computed by me (not simulated, not copied from a source) -- recheck arithmetic:
//   M/M/1 benchmark in 22.2: lambda=1/10, mu=1/8, rho=0.8, Wq=rho/(mu-lambda)=0.8/0.025=32 min,
//   Lq=rho^2/(1-rho)=0.64/0.2=3.2, L=lambda*(Wq+1/mu)=0.1*40=4. Formulas are standard M/M/1 queueing
//   theory (Little's law + standard M/M/1 results); arithmetic re-derived here, not taken from a cited table.
== 22.4 Infectious disease transmission models

Sections 22.1-22.3 introduced DES with `simmer` as a way to let simulated individuals *interact* — queue for the same nurse, compete for the same hospital bed, wait behind each other in a pathway. Infectious disease transmission models are the other major family of "interacting individual" models, and the interaction they capture is more fundamental still: one person's disease status directly changes another person's risk. If more people are infectious today, a susceptible person's chance of becoming infected tomorrow goes up. This feedback loop — formally, the *force of infection* depends on the current number of infectious individuals in the population — is what makes these models *dynamic*. It is also why you cannot decompose a transmission model into independent per-person simulations the way you could with the Markov cohort model of Chapter 19 or the microsimulation of Chapter 21: those patients never meet each other, but in a transmission model they do, and that contact is the entire mechanism of disease spread.

For a TB data analyst this should feel like familiar territory dressed in new notation: incidence depends on prevalence, prevalence depends on past incidence, and an intervention that reduces transmission today keeps paying dividends for years because it shrinks tomorrow's pool of infectious people too.

=== Compartmental models (SIR/SEIR) with `deSolve`

The classic way to represent a transmission process is to divide the population into *compartments* by disease status and write down the rate at which people move between them. The simplest version, the SIR model, has three compartments — Susceptible (S), Infectious (I), Recovered or removed (R) — governed by the ordinary differential equations:

$ dif(S,t) = - beta S I / N $
$ dif(I,t) = beta S I / N - gamma I $
$ dif(R,t) = gamma I $

where $N = S + I + R$ is the (constant) population size, $beta$ is the transmission rate (contacts per unit time multiplied by the probability of transmission per contact), and $gamma$ is the rate at which infectious people leave the infectious compartment (recovery, treatment completion, or death). The ratio $R_0 = beta slash gamma$ is the basic reproduction number — the average number of secondary infections one infectious person generates in a fully susceptible population.

Many diseases, TB among them, have a meaningful delay between becoming infected and becoming infectious. The SEIR model adds an Exposed/latent compartment (E) to capture this:

$ dif(S,t) = - beta S I / N $
$ dif(E,t) = beta S I / N - sigma E $
$ dif(I,t) = sigma E - gamma I $
$ dif(R,t) = gamma I $

where $sigma$ is the rate of progression from latent to active disease (so $1 slash sigma$ is the mean latent period).

#pitfall(
  [Real TB transmission dynamics are usually modelled with *more* than four compartments — separate latent-fast/latent-slow states, relapse pathways, drug-sensitive versus drug-resistant strains, and treatment compartments are all standard refinements in published TB transmission models. The SEIR structure here is a deliberately simplified teaching skeleton to show the mechanics of `deSolve::ode()`; a real TB policy model would need a substantially richer compartment structure built with epidemiological input, not just an R coding exercise.],
)

The `deSolve` package's `ode()` function numerically integrates a system of ODEs like these. You write an R function that takes the current time, current state, and parameters, and returns the vector of derivatives; `ode()` repeatedly evaluates it and returns the trajectory.

```r
library(deSolve)

sir_model <- function(t, y, parms) {
  S <- y["S"]; I <- y["I"]; R <- y["R"]
  with(as.list(parms), {
    N  <- S + I + R
    dS <- -beta * S * I / N
    dI <-  beta * S * I / N - gamma * I
    dR <-  gamma * I
    list(c(dS, dI, dR))
  })
}

N0     <- 10000
y0     <- c(S = N0 - 1, I = 1, R = 0)
parms  <- c(beta = 0.4, gamma = 0.2)          # R0 = beta / gamma = 2
times  <- seq(0, 180, by = 1)

out <- as.data.frame(ode(y = y0, times = times, func = sir_model, parms = parms))
```

For this toy parameterisation ($R_0 = 2$, population 10,000, one initial case) the simulation shows the classic single-wave epidemic curve: the infectious compartment rises, peaks, and then declines as the susceptible pool is depleted faster than new infections can replace it. Running the code above, the peak occurs around day 45, with roughly 15% of the population infectious at once, and by day 180 the epidemic has burned through the susceptible pool so that close to 80% of the population has been infected at some point (the final size of an unmitigated SIR epidemic with $R_0 = 2$ is a textbook result, not a coincidence of this toy run — larger $R_0$ pushes both numbers higher). The qualitative shape — rise, peak, decline, with a sizeable fraction of the population never infected because susceptibles run out before the epidemic completes — is the signature of all compartmental epidemics with $R_0 > 1$ and no reseeding.

=== Agent-based models and `EpiModel`

Compartmental ODE models assume *homogeneous mixing*: every susceptible person is equally likely to contact every infectious person, as if the population were a well-stirred soup. That assumption is convenient but often wrong — contact patterns are structured by households, workplaces, prisons, clinics, and social networks, and for diseases where a small number of contacts drive most transmission (crowded congregate settings for TB, for example), who is connected to whom matters as much as how many people are infected.

#difficult-terminology("Homogeneous mixing assumption", [
  The simplifying assumption, built into basic SIR/SEIR compartmental models, that every individual in a compartment has an equal chance of contacting every individual in every other compartment. It makes the maths tractable (you only need to track compartment *counts*, not who-contacts-whom) but breaks down when real contact structure is clustered — e.g. TB transmission concentrated within households or correctional facilities rather than spread evenly across a whole district.
])

Agent-based and network epidemic models drop that assumption: each person is an explicit simulated agent with their own contact network, and infection can only pass along an edge of that network. The R package `EpiModel` supports a spectrum of model types along this axis: deterministic compartmental models via `dcm()` (mathematically equivalent to the `deSolve` approach above), stochastic individual-level models without an explicit network via `icm()` (a microsimulation-style analogue of the compartmental model, with chance built into every transition), and full stochastic network models via `netsim()`, which first fits a dynamic contact-network model with `netest()` (built on the `ergm`/`tergm` packages) and then simulates disease spread over that evolving network. Each of the three model classes has matching `param.*()`, `init.*()`, and `control.*()` setup functions (e.g. `param.icm()`, `init.icm()`, `control.icm()` for individual contact models).

#difficult-terminology("Network epidemic model", [
  A transmission model in which the population is represented as a graph of individuals (nodes) connected by contacts or partnerships (edges), and infection spreads only along existing edges rather than between any two randomly chosen individuals. This lets the model represent real contact structure — household clusters, sexual partnership networks, prison contact networks — that a compartmental model collapses into a single average contact rate.
])

#heor-practice(
  [Reach for the compartmental ODE first. It is faster to build, faster to run, and easier to defend to a review panel that is not full of modellers. Move to an agent-based or network model only when the policy question genuinely turns on contact structure that a compartmental model cannot represent — e.g. targeting a screening programme at a specific contact network (prison, mining camp, household of an index case) rather than the general population. `EpiModel`'s `dcm()` path is a useful bridge: it lets you reuse the same parameterisation conventions as the stochastic model classes while staying in compartmental territory for a first pass.],
)

Verify the exact argument names against the installed `EpiModel` version before shipping code — package APIs for `icm()`/`netsim()` have evolved across major releases, and the signatures above reflect the documented behaviour at the time of writing rather than a guarantee for whatever version loads on your machine.

=== Linking transmission models to economic evaluation

Everything from Chapters 17-20 — discounted costs, discounted QALYs, incremental cost-effectiveness ratios — still applies once you have a transmission model. The difference is what feeds the cost and QALY accounting. In a Markov cohort or partitioned survival model, the "outcomes" are state occupancy over time for *one* cohort receiving the intervention versus a comparator cohort, each unaffected by the other. In a transmission model, you run the *same population* twice — once with the intervention (vaccination, screening, treatment scale-up) and once without — and the clinical benefit is the gap between the two epidemic curves: infections averted, cases averted, deaths averted. Those averted-event counts are then costed and weighted by QALY loss per event exactly as in a static model, and rolled up into an ICER.

#pitfall(
  [A *static* model — one that assumes the force of infection is unaffected by the intervention, usually because it was built as if the disease were non-communicable — will systematically mis-estimate the value of an infectious-disease intervention, because it misses *indirect* protection: vaccinating or treating one person also reduces the risk to everyone they would otherwise have infected (herd/community protection). Depending on the epidemiology this can make a static model understate benefit substantially, particularly for interventions delivered at a scale that meaningfully dents transmission (mass vaccination campaigns, population-wide TB active case finding) rather than individual-level care. This is a long-standing, well-documented methodological concern: the ISPOR-SMDM Modeling Good Research Practices Task Force dedicated a dedicated report to it — Pitman R, Fisman D, Zaric GS, et al. "Dynamic Transmission Modeling: A Report of the ISPOR-SMDM Modeling Good Research Practices Task Force-5." _Value in Health_ 2012;15(5):828-834 — which sets out when a dynamic transmission model is needed rather than a static decision-analytic one, precisely because the force of infection changes with the intervention and feeds back into future risk.],
)

The practical takeaway for a TB-focused reader: if the question is "how should we treat the TB patients already diagnosed," a Markov or microsimulation model of individual care pathways (Ch. 19-21) is usually adequate. If the question is "how much TB transmission will a new screening or preventive-therapy programme avert in the wider community," the force of infection is the thing the intervention is trying to change, and a dynamic transmission model is the more defensible tool.

== 22.5 Choosing between Markov, DES and dynamic models

By this point in the book you have four structurally different ways to represent disease progression and its cost/QALY consequences: Markov cohort models (Ch. 19), individual-patient microsimulation (Ch. 21), discrete event simulation (22.1-22.3), and dynamic transmission models (22.4). They share the same economic evaluation machinery downstream — costs, QALYs, discounting, ICERs — but differ fundamentally in what they can represent upstream. The single most useful question for choosing among them is: *does one simulated person's outcome change another simulated person's risk or resource access?* If no, a cohort-level or independent-microsimulation model is both correct and cheaper to run. If yes — because they compete for a shared, limited resource (DES) or because one person's infection changes another's risk of infection (dynamic transmission) — you need a model class that can represent interaction.

#ref-table(
  [Decision framework: choosing a model structure for a HEOR/HTA question],
  academic-table(
    columns: (1.1fr, 1.1fr, 1fr, 1.3fr, 0.9fr, 1.3fr),
    align: (left, left, left, left, left, left),
    header: ([*Model type*], [*Individual heterogeneity*], [*Interaction between individuals*], [*Typical use case*], [*Computational cost*], [*R package family*]),
    body: (
      [Markov cohort], [No — cohort moves as fractions between states], [No], [Chronic disease progression with a small number of health states; most standard HTA submissions], [Low], [Base R, `heemod`, hand-rolled matrices (Ch. 19)],
      [Microsimulation (independent patients)], [Yes — each patient has their own history/attributes], [No — patients simulated independently], [Pathways with memory effects (time-in-state, prior events) that a Markov model cannot track], [Moderate], [Base R loops, `hesim` (Ch. 21)],
      [Discrete event simulation], [Yes], [Yes — shared, limited resources (beds, staff, clinics)], [Capacity-constrained care pathways; operational/service-delivery questions], [Moderate-high], [`simmer` (Ch. 22.1-22.3)],
      [Dynamic transmission model], [Yes/varies by implementation (compartmental: no; agent-based/network: yes)], [Yes — infection risk depends on the number of infectious people], [Infectious disease interventions with population-level or herd effects (vaccination, mass screening)], [Low (ODE) to high (network simulation)], [`deSolve`, `EpiModel` (22.4)],
    ),
    footer: none,
  ),
) <tab-ch22-modelcompare>

#agency-note([
  This four-way decision framework is not an invented teaching device — it directly operationalises Siebert et al.'s (2012) ISPOR-SMDM Modeling Good Research Practices Task Force-3 report, already cited in Chapter 17 and Chapter 21, which lists decision trees, Markov models, partitioned survival models, microsimulation, discrete event simulation, and dynamic transmission models as a single family of choices to be made on structural grounds (what the disease/decision problem requires), not on modeller familiarity or software convenience. The DES-specific row is further detailed by Karnon et al.'s (2012) Task Force-4 report (§22.1's agency-note above); the dynamic-transmission row is further detailed by Pitman et al.'s (2012) Task Force-5 report (§22.4's pitfall above) — so every row in the table above now traces to a named, citable ISPOR-SMDM source rather than a generic "choose the right model" claim.
])

A practical rule of thumb for a TB programme analyst: start with the cheapest structure that can answer the question honestly, and only add complexity the question actually demands. A new drug regimen for diagnosed patients is a Markov or microsimulation question. A ward staffing or GeneXpert machine capacity question is a DES question. A question about how many *future* infections a screening programme prevents in the community is a dynamic transmission question — and reaching for a static model there (Markov or microsimulation) risks the herd-effect pitfall flagged in 22.4.

== 22.6 Worked example: a TB screening/preventive-therapy intervention model

This worked example uses a simplified SEIR-style compartmental model — the same `deSolve::ode()` machinery as 22.4 — to compare a TB screening-and-preventive-therapy programme against a no-intervention baseline, and to translate the difference in infections into an illustrative cost-effectiveness result.

The intervention is represented the simplest possible way an effective screening/preventive-therapy programme can be captured in a compartmental model: it reduces the effective rate at which susceptible people become infected, via a parameter `ve` applied multiplicatively to the force of infection (interpret `ve` as the population-average protective effect of the programme — a mix of coverage and per-person efficacy — not a literal per-dose vaccine efficacy).

```r
library(deSolve)

seir_model <- function(t, y, parms) {
  S <- y["S"]; E <- y["E"]; I <- y["I"]; R <- y["R"]
  with(as.list(parms), {
    N <- S + E + I + R
    force_inf <- beta * I / N * (1 - ve)
    dS <- -force_inf * S
    dE <-  force_inf * S - sigma * E
    dI <-  sigma * E - gamma * I
    dR <-  gamma * I
    list(c(dS, dE, dI, dR))
  })
}

N0    <- 100000
y0    <- c(S = N0 - 50, E = 0, I = 50, R = 0)
times <- seq(0, 10, by = 1 / 52)          # 10-year horizon, weekly steps

base_parms <- c(beta = 2.0, sigma = 1, gamma = 1, ve = 0)    # no programme, R0 = 2
int_parms  <- c(beta = 2.0, sigma = 1, gamma = 1, ve = 0.3)  # programme: 30% effective protection

out_base <- as.data.frame(ode(y0, times, seir_model, base_parms))
out_int  <- as.data.frame(ode(y0, times, seir_model, int_parms))

cum_base <- tail(out_base$I + out_base$R, 1)   # cumulative ever-infected-or-infectious, per 100,000
cum_int  <- tail(out_int$I  + out_int$R,  1)
cases_averted <- cum_base - cum_int
```

With $R_0 = beta slash gamma = 2$ and a 10-year horizon, the no-intervention run accumulates approximately 4,979 infections per 100,000 population (summing the final $I + R$ compartments, started from 50 initial cases), while the 30%-effective programme accumulates approximately 873 — a difference of about 4,106 infections averted per 100,000, roughly an 82% reduction. Because new infections keep seeding further infections in the unprotected arm, the gap between the two curves widens over the full 10-year horizon rather than staying fixed at the direct effect of the one-time intervention — this compounding is precisely the dynamic/indirect effect the pitfall in 22.4 warns a static model would miss.

// TODO-IMAGE: T24 (Ch.22) -- two-panel/overlaid deSolve::ode() epidemic-curve plot, infectious
// compartment I over the 10-year horizon, baseline vs intervention arm, showing the widening gap.
#figure(
  image("../images/r_generated/ch22_seir_epidemic_curves.png", width: 85%),
  caption: [Infectious compartment (I) over the 10-year horizon from the `deSolve::ode()` SEIR model above: no-intervention baseline vs the 30%-effective screening/preventive-therapy programme. The gap between the curves widens over time rather than staying fixed at the size of the one-time intervention, illustrating the compounding/indirect-protection effect that a static model would miss (the pitfall in 22.4).],
) <fig-ch22-seir>

Costing this illustratively (figures below are for demonstration only, not real TB unit costs):

```r
cost_per_case        <- 1500   # USD, illustrative TB treatment cost per active case
qaly_loss_per_case    <- 0.15  # illustrative QALY loss per active TB episode
cost_per_covered      <- 8     # USD, illustrative programme cost per person covered
coverage              <- 0.7
n_covered             <- N0 * coverage

cost_averted_treatment <- cases_averted * cost_per_case
qaly_gained             <- cases_averted * qaly_loss_per_case
intervention_cost       <- n_covered * cost_per_covered
net_budget_impact       <- intervention_cost - cost_averted_treatment
```

Carrying the arithmetic through: `cases_averted` $approx 4106$, so treatment cost averted $approx 4106 times \$1500 approx \$6.16$ million; QALYs gained $approx 4106 times 0.15 approx 616$; programme cost for 70,000 people covered at \$8 each is $70000 times 8 = \$560000$; net budget impact is $\$560000 - \$6.16"M" approx -\$5.60$ million (i.e. the programme is cost-*saving* once averted treatment costs are counted), and because it is both less costly and more effective it is a dominant strategy rather than one with a conventional positive ICER.

#report-table(
  [Illustrative TB screening/preventive-therapy programme vs no intervention, 10-year horizon per 100,000 population (toy model, demonstration figures only)],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Outcome*], [*No intervention*], [*Screening programme*], [*Difference*]),
    body: (
      [Cumulative infections (I + R) at 10y], [4,979], [873], [-4,106 (-82.5%)],
      [Peak infectious prevalence], [1,417], [153], [-1,264],
      [TB treatment cost (illustrative), USD], [\$7.47M], [\$1.31M], [-\$6.16M],
      [QALYs lost to active TB (illustrative)], [747], [131], [+616 gained],
      [Programme cost (illustrative), USD], [\$0], [\$560,000], [+\$560,000],
      [Net budget impact (illustrative), USD], [--], [--], [-\$5.60M (savings)],
    ),
    footer: none,
  ),
) <tab-ch22-tbscreen-result>

The headline qualitative finding — that the programme is cost-saving and QALY-gaining in this toy parameterisation — is an artefact of the chosen illustrative unit costs and efficacy, not a real-world TB finding; a real submission would need locally sourced unit costs, a properly validated TB natural-history structure, and a sensitivity analysis over `beta`, `ve`, and coverage before anyone could rely on the ICER sign.

// OPEN ITEMS for assembler review:
// 1. EpiModel function signatures (dcm(), icm(), netsim(), param.icm()/init.icm()/control.icm(), netest()) were verified against
//    current CRAN documentation (search.r-project.org/CRAN/refmans/EpiModel) at time of writing, but the text explicitly hedges
//    that argument names have changed across major EpiModel releases -- recommend assembler spot-check against whatever EpiModel
//    version the book's reproducibility environment pins.
// 2. Pitman et al. 2012 ISPOR-SMDM Task Force-5 citation (Value in Health 15(5):828-834) was verified via web search
//    (ispor.org article page + PubMed record, PMID 22990086) -- citation details (volume/issue/pages) should be double-checked
//    against the assembler's reference-management system/bibliography file for consistent formatting with the rest of the book.
// 3. All numeric claims in 22.4's toy SIR example (R0=2, peak I ~15.3% of N at day 45, final attack rate ~79.7%) and in 22.6's
//    worked example (cumulative infections 4,979 vs 873 per 100,000 at 10y, infections averted ~4,106, ~82.5% reduction,
//    peak I 1,417 vs 153, cost/QALY/net-budget figures) were computed by actually running deSolve::ode() in R during drafting
//    (not asserted from memory) -- assembler should re-run the embedded code blocks verbatim as a final check that the printed
//    numbers match code output before publication, since any later edit to the code blocks (e.g. changing beta/gamma/ve) would
//    silently invalidate the prose numbers.
// 4. The cost-per-case/QALY-loss/programme-cost figures in 22.6 are explicitly illustrative/invented for pedagogical arithmetic
//    consistency, not sourced from real TB costing literature -- flagged in-text twice; do not let these propagate as if they
//    were real unit costs elsewhere in the book.
