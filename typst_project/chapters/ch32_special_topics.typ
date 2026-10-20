#import "../common.typ": *

= Chapter 32. Special Topics

#learning-objectives((
  [Extrapolate immature oncology survival data and justify cure-fraction assumptions against NICE DSU TSD 21.],
  [Explain why ultra-rare-disease HTA relies on single-arm trials, historical controls, and Bayesian borrowing, and how NICE's Highly Specialised Technologies route differs from standard appraisal.],
  [Distinguish when a vaccine evaluation requires a dynamic transmission model rather than a cohort Markov model, and why a societal perspective and multi-year budget impact both matter.],
  [Model a diagnostic's full test-and-treat pathway, carrying sensitivity/specificity through to all four classification outcomes rather than compressing them into a single accuracy statistic.],
  [Evaluate the evidence-generation and re-review challenges specific to digital health technologies and AI-enabled interventions, grounded in NICE's Evidence Standards Framework.],
  [Parameterise a durability/waning-of-effect assumption for one-time curative therapies and connect it to outcomes-based managed entry agreements and staged-payment models.],
  [Extend the book's TB case study with an explicit cascade-of-care structure linking diagnosis, treatment initiation, and completion to the Chapter 19 Markov model and Chapter 22 transmission model.],
  [Situate single-technology HTA within system-level, budget-constrained resource allocation and opportunity cost.],
))

== 32.1 Oncology: immuno-oncology, long-term survival and cure assumptions

Oncology occupies a disproportionate share of HTA agency workload relative to its share of the pharmaceutical pipeline, and for a structural reason: cancer trials are usually analysed and submitted for reimbursement long before most patients have died. A trial might report a median follow-up of two or three years, while the economic model needs to project survival, and therefore cost and QALYs, over a patient's remaining lifetime -- frequently decades for younger patients or for cancers with genuinely durable responses. This gap between what the trial has observed and what the model needs to claim is the central methodological challenge of oncology HTA, and it is worth naming explicitly.

#difficult-terminology("immature survival data")[
  Survival data are "immature" when a substantial fraction of patients in a trial have not yet died (or progressed) at the time of the data cut used for the HTA submission -- the Kaplan-Meier curve has not flattened out or reached its tail, so the shape of that tail is unknown and must be estimated rather than observed.
]

With immature data, the analyst cannot simply read off long-term survival from the trial; some assumption about what happens after the last observed event is unavoidable. Chapter 12 already walked through the mechanics of fitting standard parametric survival distributions with `flexsurv::flexsurvreg()` -- exponential, Weibull, log-normal, log-logistic, Gompertz, and generalized gamma -- and this chapter does not repeat that derivation. What matters here is the HTA-specific framing: each of these distributions encodes a different assumption about how the hazard of death behaves beyond the observed follow-up (constant, monotonically increasing, bathtub-shaped, and so on), and because oncology economic models are overwhelmingly sensitive to this choice, the extrapolated curve -- not the within-trial efficacy estimate -- is routinely the single most scrutinized element of an oncology submission.

#agency-note[
  NICE's Decision Support Unit Technical Support Document 21, *Flexible Methods for Survival Analysis*, is the standard reference UK reviewers and submitting companies use when standard parametric distributions are judged inadequate to capture complex hazard shapes. It covers flexible parametric (spline-based) models, piecewise and landmark approaches, and models that explicitly build in a cure proportion. It supplements, rather than replaces, the standard distributions covered in TSD 14 on survival analysis for economic evaluation, and reviewers will typically expect to see a justified choice among several candidate models, backed by visual fit, statistical fit criteria (AIC/BIC), and -- critically -- clinical plausibility checks against external data such as registry or general-population mortality.
]

Immuno-oncology (IO) agents raise a further, more specific question. Several checkpoint inhibitors and related therapies produce Kaplan-Meier curves with a distinctive shape: an initial period where the treatment and comparator arms separate only modestly, followed by a plateau in the treatment arm's survival curve that persists for years, consistent with a subgroup of patients achieving a durable, perhaps lifelong, response. This pattern motivates a different extrapolation strategy: the cure assumption.

#difficult-terminology("cure-fraction model")[
  A cure-fraction model (or "cure model") is a survival model that explicitly assumes a proportion of the trial population -- the cure fraction -- will experience no excess risk of death from the disease once they pass some point, behaving thereafter like the general population (or a disease-free reference group), while the remaining patients continue to follow a standard survival distribution. It is a structural assumption layered on top of the underlying hazard model, not a new distributional family in its own right.
]

#difficult-terminology("mixture cure model")[
  In a mixture cure model, the overall survival function is modelled as a weighted combination of two distinct groups: an "immune"/cured fraction (whose future mortality follows background population rates) and an "uncured" fraction (whose mortality follows a chosen parametric distribution, e.g. Weibull). The weight -- the estimated cure fraction -- is itself a model parameter, typically allowed to depend on treatment arm or covariates. This contrasts with non-mixture cure models, which instead rescale a single survival distribution so it asymptotes towards the cure proportion as time extends, without separating patients into two latent groups.
]

Cure models are seductive in oncology HTA because they map neatly onto a clinical narrative ("some patients are effectively cured") and because, when the plateau is genuine, they can produce a more clinically plausible long-term extrapolation than forcing a conventional monotonic hazard distribution through a flattening curve. But they are exactly as scrutinized as plain parametric extrapolation, if not more so, because the cure fraction is frequently the parameter with the least statistical support in the data (it depends on what happens in the thin right-hand tail of the curve, which is precisely where follow-up is shortest) and because overestimating it inflates lifetime QALYs substantially.

#pitfall[
  A cure-fraction assumption is a clinical claim wearing a statistical costume. Fitting a mixture cure model to five years of follow-up data does not, by itself, demonstrate that any patient is cured -- it demonstrates that a flattening pattern is consistent with a cure structure under the chosen distributional family. Reviewers at NICE, the Institute for Clinical and Economic Review (ICER), and other agencies will typically ask for external corroboration: longer natural-history data, registry evidence, biological rationale for why durable response should translate to cure, and sensitivity analyses that show how the ICER moves if the cure fraction is wrong by a plausible margin. A model whose base case depends entirely on an unsupported cure assumption is one of the most common reasons an oncology submission is sent back for further work.
]

The R code below illustrates the mechanics using a small, clearly simulated oncology-style dataset -- a single-arm cohort with a plateauing late-period survival pattern, of the kind the cure-model literature typically discusses, reframed here in the TB-model spirit used earlier in the book (think of it as a hypothetical immunotherapy for a TB-associated malignancy, used purely to keep the running case-study thread intact; the numbers are illustrative, not drawn from any real trial).

```r
library(flexsurv)
library(flexsurvcure)
library(survival)

set.seed(32104)
n <- 250

# Simulate a cure fraction: ~30% of patients never experience
# the event and are administratively censored at end of follow-up;
# the remainder follow a Weibull hazard.
true_cure_fraction <- 0.30
is_cured <- rbinom(n, 1, true_cure_fraction)
followup_end <- 60  # months of trial follow-up

event_time <- ifelse(
  is_cured == 1,
  followup_end + 1,                      # cured: would never see the event
  rweibull(n, shape = 1.3, scale = 18)   # uncured: standard Weibull hazard
)

obs_time  <- pmin(event_time, followup_end)
event_ind <- as.numeric(event_time <= followup_end)

onc_data <- data.frame(time = obs_time, status = event_ind)

# A standard (non-cure) Weibull fit, as covered conceptually in Chapter 12,
# forces a single monotonic hazard through the whole curve:
fit_weibull <- flexsurvreg(
  Surv(time, status) ~ 1,
  data = onc_data,
  dist = "weibull"
)

# A mixture cure model explicitly separates a cured fraction from an
# uncured Weibull-distributed group:
fit_cure <- flexsurvcure(
  Surv(time, status) ~ 1,
  data = onc_data,
  dist = "weibull",
  mixture = TRUE,
  link = "logistic"
)

print(fit_cure)
# The fitted "theta" parameter is the estimated cure fraction, which can be
# compared against the simulated true_cure_fraction (0.30) as a sanity check,
# and against external long-term data where available.
```

Running this on the simulated data recovers an estimated cure fraction in the neighbourhood of the simulated truth, and the model object exposes the same mean- and restricted-mean-survival machinery (`mean()`, `summary()`) used for standard `flexsurvreg` fits, so the downstream link into a cost-effectiveness model (converting the fitted survival function into Markov transition probabilities or partitioned-survival curves, as covered in Chapters 10-11) is unchanged in mechanics. What changes is the burden of justification: every extra year the cure fraction is extrapolated forward is a year of QALYs and costs an agency reviewer will want defended against something other than the shape of the curve itself.

== 32.2 Rare diseases and ultra-orphan drugs

The standard cost-effectiveness paradigm -- a randomized trial of meaningful size, feeding a cost-per-QALY model judged against a single threshold -- was built with common conditions in mind. It strains badly once applied to ultra-rare diseases, where the entire eligible national population may number in the dozens or low hundreds. Four features recur and compound each other: trials are necessarily tiny, sometimes single-arm because randomizing a handful of patients against placebo is neither feasible nor ethical; per-patient treatment costs are often extremely high, since the full cost of development must be recovered from a tiny patient base; natural history data (how the untreated disease actually progresses) is often poorly characterised because so few patients have ever been studied; and the resulting incremental cost-effectiveness ratios (ICERs) frequently land far above thresholds that would sink a submission for a common disease.

Agencies have responded with dedicated pathways rather than simply waiving the standard rules. NICE operates a distinct Highly Specialised Technologies (HST) programme, sitting alongside its standard Technology Appraisal process, for treatments of very rare conditions (broadly, conditions affecting a very small number of patients in England, with the committee applying additional eligibility criteria set out in its methods manual). The HST programme uses a materially different, and higher, cost-effectiveness ceiling than NICE's standard appraisals: NICE's published manual for technology appraisal and highly specialised technologies sets the standard reference-case threshold range at £20,000-£30,000 per QALY (now updated to £25,000-£35,000 following recent government-directed changes), while HST evaluations use a base threshold of £100,000 per QALY, which can rise further -- NICE's own published guidance describes a weighting scheme allowing the effective threshold to climb toward £300,000 per QALY for treatments that demonstrate very large incremental QALY gains. Other jurisdictions build similar but not identical accommodations: for example, several health systems apply separate review tracks, modified evidentiary expectations, or managed-entry/outcomes-based arrangements specifically earmarked for orphan and ultra-orphan products, rather than forcing them through the identical process used for common-disease submissions. The details differ by agency and change over time, so any specific claim about a non-UK pathway should be checked against that agency's current published methods guide rather than assumed from general reputation.

#difficult-terminology("single-arm trial")[
  A single-arm trial enrolls patients onto the investigational treatment only, with no concurrent randomized comparator group. All patients receive the drug being studied; effectiveness is assessed against some external benchmark (historical data, a different trial, or a modelled natural-history estimate) rather than against patients from the same trial who received standard care. Single-arm designs are common in ultra-rare disease and some oncology indications because recruiting enough patients for two arms is impractical, but they remove randomization's main statistical protection: without a concurrent control, any difference between the treated cohort's outcomes and an external benchmark could reflect real treatment effect, or could reflect differences between the two populations, time periods, or measurement methods.
]

#difficult-terminology("historical control")[
  A historical control is a comparator group drawn from data collected before, or separately from, the trial being evaluated -- for example, outcomes of patients treated under prior standard of care, often from medical records, a disease registry, or a previously published natural-history study. Historical controls let a single-arm trial be compared against *something*, but the comparison is only as good as how similar the historical population truly is to the trial population in case-mix, era of care, and measurement -- differences that are easy to overlook and hard to fully correct for statistically.
]

Because randomized comparison is often unavailable, rare-disease evaluators lean on a narrower set of methodological workarounds, each partial and each itself contestable in review. Comparing the single-arm trial's outcomes against a historical control dataset is the most direct approach, usually paired with some adjustment technique (matching or weighting on observed prognostic factors) to reduce the risk that any apparent benefit is really a difference between the two populations rather than the drug. A related, more formally Bayesian approach is to treat external data -- historical trials, registries, or even data from a similar but not identical disease -- as prior information that is statistically "borrowed" into the analysis of the new, tiny trial, down-weighting the external evidence according to how comparable it is judged to be, a technique generally referred to as Bayesian borrowing of external data (with methods such as power priors and commensurate priors used to formalise the down-weighting). All of these approaches aim at the same unavoidable problem: in an ultra-rare disease, a fully internally-valid randomized comparison may simply not be obtainable, and the HTA question becomes less "is this evidence perfect" and more "is this the best evidence that could plausibly exist for this population, and has its residual uncertainty been reflected honestly in the economic model."

A short, deliberately simple R illustration of the single-arm-versus-historical-control comparison follows. It is not an implementation of any specific named statistical method (propensity score matching, MAIC, or a particular Bayesian borrowing prior) -- those are substantial topics each deserving their own careful treatment -- but a sketch of the basic comparison an analyst would start from before applying any such adjustment.

```r
library(survival)

# Tiny single-arm trial: n = 18 patients on the new ultra-orphan therapy
trial_data <- data.frame(
  time   = c(4, 7, 9, 11, 14, 15, 18, 20, 22, 25, 27, 30, 33, 36, 40, 44, 48, 52),
  status = c(1, 1, 1, 0,  1,  1,  0,  1,  1,  0,  1,  1,  0,  1,  0,  1,  0,  1),
  group  = "new_therapy"
)

# A small historical-control dataset, e.g. extracted from a disease
# registry describing outcomes under prior standard of care
historical_data <- data.frame(
  time   = c(2, 3, 5, 6, 8, 8, 10, 12, 13, 15, 16, 18, 19, 21, 23, 26, 28, 31),
  status = c(1, 1, 1, 1, 1, 1, 1,  1,  0,  1,  1,  0,  1,  1,  0,  1,  1,  1),
  group  = "historical_control"
)

combined <- rbind(trial_data, historical_data)
combined$group <- factor(combined$group, levels = c("historical_control", "new_therapy"))

fit <- survfit(Surv(time, status) ~ group, data = combined)
print(fit)

# An unadjusted Cox model gives a first-pass, honestly crude estimate of the
# association -- it does NOT control for the two groups potentially differing
# in age, disease severity, or era of care, which is exactly the limitation
# that a matching or Bayesian-borrowing approach would need to address before
# this comparison could support a cost-effectiveness claim.
cox_fit <- coxph(Surv(time, status) ~ group, data = combined)
summary(cox_fit)
```

The honest reading of this kind of output is narrower than it looks: a hazard ratio from an unadjusted comparison between a trial cohort and a historical dataset is a starting hypothesis, not a causal estimate, and an HTA submission built on it will be expected to show what was done to address the comparability problem, and how much residual uncertainty remains once that is done.

== 32.3 Vaccines and public health programmes

Vaccine economic evaluation shares a vocabulary with drug cost-effectiveness analysis -- QALYs, ICERs, discounting -- but its structure is different enough that treating a vaccine like "a drug given once" routinely produces a misleading model. The central reason is indirect protection.

Most drug CEAs model each patient's outcomes as if they were independent of what happens to everyone else in the model: vaccinating patient A does not change patient B's risk. Vaccines against transmissible infections break this assumption directly. When enough of a population is immunized, the pathogen has fewer susceptible hosts to spread between, so even unvaccinated individuals benefit from a lower circulating force of infection -- the phenomenon generally known as herd immunity or indirect protection. A standard cohort Markov model, of the kind used throughout earlier chapters, has no mechanism for one simulated patient's vaccination status to alter another simulated patient's risk; it treats transition probabilities as fixed inputs, not as outputs of population-level transmission dynamics. Once indirect effects matter to the policy question -- which they typically do for any vaccination programme aimed at a transmissible disease -- the standard cohort approach understates the benefit of vaccination, sometimes substantially, because it is blind to everyone who never gets infected simply because the people around them were vaccinated.

This is precisely the gap that dynamic transmission models are built to close. Chapter 22 covered discrete-event simulation and dynamic transmission modelling in general terms; the relevant point to carry forward here is narrower: whenever a vaccine evaluation needs to capture herd effects -- which is most vaccine evaluations, outside of some narrow travel-vaccine or purely individual-protection scenarios -- a compartmental or agent-based transmission model that lets the force of infection respond to coverage is the structurally appropriate tool, not a cohort Markov model adapted after the fact. Choosing a cohort model for a question that hinges on herd protection is a structural mismatch, not a simplifying approximation, and it is one of the more common and more consequential modelling errors in vaccine HTA.

#heor-practice[
  Before building a vaccine economic model, settle one question first: does the policy decision hinge on indirect protection? If coverage is low, the disease is non-transmissible between humans (e.g. tetanus), or the comparator is "no programme at all" in a population too small for meaningful transmission dynamics, a cohort approach may be defensible. If the question is "what happens to transmission, and therefore to everyone's risk, as coverage rises from 40% to 80%," a dynamic transmission model is close to unavoidable, and the choice should be stated and justified explicitly in the modelling report rather than left implicit in the model's structure.
]

Vaccine evaluations also tend to adopt a broader analytic perspective than the typical drug submission. Many HTA reference cases for pharmaceuticals are built around a health-system (payer) perspective -- what does the health system spend, what health does it buy. Vaccination programmes, especially paediatric ones, more often justify a societal perspective, explicitly including costs and outcomes that a narrower payer view would exclude: caregiver time lost attending vaccination visits or nursing a sick child, productivity losses from parents' missed work, and broader economic consequences of outbreaks (school closures, workplace absence) that a pure health-system ledger does not capture. Whether this broader perspective is required, optional, or simply reported alongside a narrower base case depends on the specific agency's reference case, but the tendency toward including these elements recurs across jurisdictions precisely because vaccination's benefits spill so far beyond the vaccinated individual's own clinical outcomes.

Finally, vaccination programmes are rarely a one-off decision in the way a single patient's drug treatment is. A national immunization programme is a multi-year, multi-cohort commitment: every year's birth cohort (or every catch-up campaign) adds a new tranche of vaccinated patients, procurement and cold-chain logistics scale with coverage targets, and the cumulative budget impact compounds across years in a way a single-patient ICER does not convey. This is exactly the territory Chapter 23's budget impact analysis addressed -- year-by-year affordability under a fixed overall health budget, as distinct from the lifetime cost-effectiveness question -- and vaccine programme appraisals typically need both pieces: a cost-effectiveness case (is this a good use of resources per QALY) and a budget impact case (can the system afford to roll this out across the population over the relevant time horizon), reported alongside each other rather than collapsed into one number.

At the global level, the World Health Organization plays a coordinating and standard-setting role for vaccine economic evaluation, particularly for low- and middle-income countries (LMICs) that may lack the capacity to run a full bespoke HTA process for every new vaccine decision. WHO's Strategic Advisory Group of Experts on Immunization (SAGE) reviews evidence and issues policy recommendations that inform national immunization programmes, and WHO more broadly has long promoted the use of cost-effectiveness analysis -- including dynamic transmission modelling where indirect effects are material -- as part of the evidence base national immunization technical advisory groups (NITAGs) are expected to draw on when deciding whether and how to introduce a new vaccine. The precise methodological guidance documents WHO has issued have evolved over time and vary by vaccine and disease area, so this chapter deliberately does not attribute a specific recommendation to a specific named WHO document; the durable point for an HEOR analyst working in or for an LMIC setting is that WHO guidance, together with Gavi and regional technical bodies, forms an important reference layer above individual national HTA processes, and any current submission should be checked against WHO's currently published immunization economics guidance rather than against what this chapter can verify at time of writing.

== 32.4 Diagnostics, screening and medical devices

A drug's value proposition in HTA is relatively self-contained: give the drug, observe the clinical effect, model the downstream costs and outcomes of that effect. A diagnostic test's value proposition is not self-contained in the same way, and this is the single most important structural difference to internalise before building a diagnostics or screening economic model: a test, by itself, changes nothing about a patient's health. A test only has value through what happens *after* the result -- the treatment decision it informs, the earlier or later intervention it triggers, or the reassurance (or anxiety) it produces. Modelling a diagnostic in isolation from the downstream clinical pathway, as though the test result were the outcome of interest, is a category error, and it is why diagnostic economic models are typically built around the full test-and-treat pathway rather than around test accuracy statistics alone.

This has a direct and unforgiving consequence for how sensitivity and specificity -- covered in Chapter 6 in the context of diagnostic test accuracy and meta-analysis, and not re-derived here -- enter the model. Every imperfect test produces false positives and false negatives, and each type of error carries its own downstream cost and outcome consequence that must be modelled explicitly rather than summarised away. A false positive sends a patient without the disease into unnecessary further investigation or treatment, incurring cost, potential harm from the intervention itself, and psychological burden, with no corresponding health gain. A false negative does the opposite and arguably worse: a patient with the disease is reassured and sent away, delaying treatment until the disease presents more advanced, at higher cost and worse prognosis than if it had been caught at the point of testing. Because these two error types have different downstream cost and outcome profiles, a diagnostics economic model generally needs branches in the decision tree (or equivalent model structure) for all four classification outcomes -- true positive, false positive, true negative, false negative -- each flowing into whatever happens next in the clinical pathway, rather than a single aggregate "accuracy" parameter feeding a single cost-effectiveness number.

#pitfall[
  It is tempting to summarise a diagnostic's performance with a single number -- area under the ROC curve, or overall accuracy -- and feed that into an economic model as if it captured the relevant trade-off. It does not. A test with 95% overall accuracy can still be economically disastrous if its errors are concentrated in false negatives for a severe, treatable condition, because the cost of a missed case (delayed treatment, worse outcome, potentially higher downstream cost) can dwarf the modest savings from avoiding unnecessary follow-up on the correctly-identified negatives. Sensitivity and specificity must be carried through the model as separate parameters feeding separate downstream branches, not compressed into one headline statistic before the economic consequences are attached.
]

NICE evaluates diagnostic and device technologies through two distinct, real, named pathways that sit alongside its drug-focused Technology Appraisal programme: the Diagnostics Assessment Programme (DAP), which handles diagnostic technologies where the evaluation is complex -- often because the test's adoption would increase net NHS cost and a full cost-effectiveness case needs to be made -- and the Medical Technologies Evaluation Programme (MTEP), which evaluates medical devices and simpler diagnostics, generally using a cost-minimisation approach where the question is less "is the health gain worth the extra cost" and more "does this device or test deliver equivalent or better outcomes at equal or lower cost than current practice." Which programme a given technology is routed to depends on whether its likely profile resembles a cost-increasing, outcome-improving case (DAP) or a cost-saving or cost-neutral case (MTEP); NICE's methods manual for health technology evaluations describes both programmes, alongside the HST and Technology Appraisal programmes discussed earlier in this chapter, as sitting together under its Centre for Health Technology Evaluation.

#difficult-terminology("MTEP/DAP")[
  MTEP (Medical Technologies Evaluation Programme) and DAP (Diagnostics Assessment Programme) are two of NICE's named evaluation routes specifically for devices and diagnostic tests, distinct from the drug-focused Technology Appraisal and the ultra-rare-disease-focused Highly Specialised Technologies programmes covered earlier in this chapter. The practical distinction an analyst should hold onto is MTEP's use of cost-minimisation for technologies expected to be cost-saving or cost-neutral, against DAP's full cost-effectiveness modelling for technologies expected to raise net cost in exchange for better outcomes.
]

Beyond the test-and-treat pathway and the sensitivity/specificity trade-off, device and diagnostic HTA carries its own distinct evidentiary challenges that differ from pharmaceutical evaluation in kind, not just degree. Innovation cycles are typically much shorter than for drugs -- a device or test may be meaningfully revised (new generation, updated software, refined assay) well before an HTA agency has finished evaluating the version currently in front of it, which creates a persistent risk that the evidence being appraised lags the product actually being deployed. Many devices, particularly surgical and interventional ones, exhibit learning-curve effects, where outcomes measurably improve as the operating clinician or centre gains experience with the technology, meaning early trial results may understate the device's real-world performance once it has been in routine use for some time, and comparative evidence is often structurally weaker than in pharmaceutical RCTs, since blinding a surgeon or patient to which device or procedure was used is frequently impossible, randomization can be harder to justify or recruit for, and device trials are more often small, single-centre, or registry-based rather than large multi-site RCTs. None of these features invalidates device and diagnostic HTA, but each one means the analyst building the economic model should expect, and explicitly address, more structural uncertainty than the equivalent drug submission would typically carry.

== 32.5 Digital health technologies and AI-enabled interventions

Every therapy-area example so far in this chapter -- and in the book overall -- has shared a quiet assumption: the technology under evaluation is fixed at the point of submission. A tablet's formulation does not change between the ERG's technical engagement and the committee meeting; a Study 31/A5349-style regimen does not silently update its dosing algorithm overnight. Digital health technologies (DHTs) -- smartphone apps, clinician-facing decision-support software, software-as-a-medical-device (SaMD) diagnostic or triage tools, and increasingly AI-driven variants of all three -- break that assumption, and the break is structural, not incidental.

The mismatch starts with timelines. A typical NICE technology appraisal, from company submission to final guidance, runs many months; a software product under active development can ship a meaningfully different version -- a retrained model, a new triage threshold, a redesigned user interface that changes adherence -- several times in that same window. An HTA process built around evaluating a stable artefact is being asked to evaluate a moving target, and the evidence base that supported the original submission may no longer describe the version of the product actually in use by the time guidance is published.

The second mismatch is about what counts as a comparator. A new antihypertensive has an obvious comparator: the current standard-of-care drug, evaluated head-to-head in a randomised trial. A chatbot-based symptom-triage tool has no equally obvious comparator. Is the relevant comparison a nurse-led telephone triage line? No triage at all (patients self-refer)? A different app? Each choice implies a different trial design, a different outcome set, and potentially a different conclusion about value -- and unlike a drug trial, blinding is often impossible (a clinician or patient usually knows whether they are using the app), and the "intervention" itself may be a bundle of features that interact with local workflow in ways a single multi-centre RCT struggles to capture cleanly.

#pitfall[
  Resist the temptation to treat "we built an app and measured an outcome before and after it was introduced" as equivalent in evidential weight to a randomised comparison, even when a true RCT is genuinely hard to run for a digital tool. A pre/post design cannot rule out secular trends, regression to the mean, or a Hawthorne effect (performance improving simply because staff know they are being observed/measured) as alternative explanations for an observed improvement. Where a true RCT is infeasible, a stepped-wedge cluster design or an interrupted-time-series analysis with enough pre-intervention data points to model the counterfactual trend are far more defensible than a simple two-point before/after comparison, and reviewers increasingly expect the stronger design or an explicit justification for why it was not used.
]

NICE's response to this evidence problem is a real, named framework worth knowing by name: the *Evidence Standards Framework for Digital Health Technologies* (ESF), first published in 2018-2019 in collaboration with NHS England, Public Health England, and MedCity, and updated since. Rather than applying one fixed evidence bar to every DHT, the ESF classifies a technology into a functional tier -- broadly, from DHTs that merely provide general information or system-navigation support, through DHTs that encourage health-related behaviour change or self-management, up to DHTs that diagnose, treat, actively monitor, or calculate a care-relevant score -- and attaches a graduated evidence standard to each tier: lower-risk, lower-function tiers can satisfy the framework with lighter evidence (clear description of the product's intended function and basic data-protection/usability assurances), while higher-function, higher-risk tiers (an app that recommends a specific clinical action, for instance) are expected to show evidence closer to that of a conventional clinical evaluation, including, where economic claims are made, a clear description of the cost-comparator relationship. The ESF explicitly notes that satisfying it does not mean NICE has assessed or endorsed the product -- it is a standard developers and commissioners can use for consistency, separate from a full NICE technology appraisal.

#difficult-terminology("Software as a medical device (SaMD)")[
  Software as a medical device is software intended to be used for a medical purpose (diagnosis, prevention, monitoring, treatment, or management of a disease or condition) that performs that purpose without being embedded inside a physical hardware medical device -- the software itself, running on a general-purpose smartphone or server, *is* the medical device from a regulatory standpoint. This matters for HTA because SaMD typically also needs to clear a separate regulatory bar (in the UK, UKCA/CE marking as a medical device, with higher-risk SaMD requiring deeper regulatory scrutiny) before an HTA body considers reimbursement at all -- a drug and an AI triage app both need to prove safety and effectiveness, but they travel through entirely different regulatory gateways to get to the point where an HTA evaluation is even relevant.
]

AI-enabled tools sharpen every one of these problems further, because of a feature no drug or static device shares: the model itself can change after deployment without any physical change to a pill or a device. A machine-learning diagnostic or triage algorithm is typically validated on the data available at the time of training, then deployed into a different population, a different case mix, or a different point in time -- and its performance can degrade as the real-world data distribution it sees in practice drifts away from its training distribution. This is usually called *model drift* or *dataset shift*, and it raises a genuinely hard regulatory and HTA question that has no fully settled answer yet: if a vendor retrains the underlying model on new data and pushes an update, is that update still "the same" technology that was originally evaluated, or does it need re-evaluation as effectively a new product? Regulators (including the UK's MHRA and the US FDA, which has published thinking on a "predetermined change control plan" concept for AI/ML-based SaMD) are actively working through exactly this question, and an HTA body downstream of that regulatory decision inherits the same ambiguity: a cost-effectiveness conclusion reached for version 1.0 of an algorithm is not automatically a valid conclusion about version 1.4 if the retraining has materially changed sensitivity, specificity, or the population on which it was validated.

#agency-note[
  Treat any specific claim about how frequently an AI-enabled DHT must be re-reviewed after a model update, or exactly what triggers mandatory re-submission, with appropriate caution -- this is an actively evolving area of both UK (MHRA, NICE ESF) and international regulatory and HTA policy rather than a single settled rule, and an analyst building an economic case for an AI diagnostic tool should confirm the current position directly with the relevant regulator and HTA body rather than assuming last year's guidance still applies unchanged.
]

For an R-based analyst, the practical implication of all this is less about a new statistical method and more about structuring the economic evaluation so that the comparator, the outcome measurement window, and (where relevant) the specific model version under evaluation are all explicit, versioned inputs rather than implicit assumptions baked into a single hardcoded analysis.

```r
# Framing a digital triage tool's evaluation data: explicit comparator
# and model-version fields, not assumed constants. Illustrative/simulated.
library(dplyr)

triage_eval <- tibble::tibble(
  patient_id      = 1:6,
  arm             = c("app_triage", "app_triage", "nurse_telephone",
                      "nurse_telephone", "app_triage", "nurse_telephone"),
  model_version   = c("v1.2", "v1.2", NA, NA, "v1.3", NA),
  correct_triage  = c(TRUE, FALSE, TRUE, TRUE, TRUE, FALSE),
  time_to_advice_min = c(4, 6, 22, 19, 3, 25)
)

triage_eval %>%
  group_by(arm, model_version) %>%
  summarise(
    accuracy      = mean(correct_triage),
    mean_wait_min = mean(time_to_advice_min),
    .groups = "drop"
  )
```

Keeping `model_version` as an explicit column -- even when, as here, it is `NA` for the non-AI comparator arm -- forces the analysis to surface rather than silently absorb the question of which version of the technology actually generated the evidence, which is exactly the traceability an ESF-style evaluation or an ERG re-review is likely to ask for.

== 32.6 Gene and cell therapies and outcome-based agreements

Gene and cell therapies -- one-time infusions intended to correct or replace a genetic defect, or engineered cell products such as CAR-T therapies for certain blood cancers -- pose an HTA challenge that is structurally different from anything else in this chapter, because the payment event and the benefit-realisation period are pulled apart to an extreme not seen even in oncology's immature-survival-data problem from §32.1. A conventional drug is paid for roughly in proportion to how long it is used; a curative (or potentially curative) one-time gene therapy is typically billed as a single very large payment at the point of infusion, while the health benefit it is meant to deliver -- years, ideally decades, of avoided disease progression -- is realised gradually, long after the bill has already been paid in full.

That timing mismatch collides directly with the evidence available at launch. Because these are typically among the newest therapies to reach any regulator, the clinical trials supporting approval are necessarily young: follow-up of a few years at most, sometimes only one or two, for a therapy whose entire value proposition rests on effects assumed to last for decades. This is the same immature-data problem introduced for oncology survival curves in §32.1, but it lands with different payment-mechanism consequences here -- an oncology drug's cost accrues gradually over a treatment course, so an unexpectedly short survival benefit is at least partially offset by a correspondingly shorter period of drug spend. A one-time gene therapy's cost is already fully sunk the moment durability turns out to be shorter than assumed; there is no remaining spend to claw back through ordinary discontinuation.

#difficult-terminology("Durability (waning of effect)")[
  Durability, in this context, refers to how long a treatment's benefit persists once achieved, and "waning of effect" describes the possibility that the benefit is not permanent -- that patients who initially respond or are cured may, at some point after treatment, begin losing that benefit, whether through biological relapse, loss of corrected gene expression over time, or simple regression toward the underlying disease's natural history. The term matters specifically for curative or one-time therapies because a model that simply assumes "cured means cured forever" is making an extrapolation decision just as consequential as the survival-curve extrapolation decisions covered in §32.1 -- except here the data to inform that decision (long-term durability data beyond the trial's follow-up window) frequently does not exist yet at the time the therapy is first evaluated.
]

Payers and manufacturers have converged, imperfectly but consistently, on *outcome-based managed entry agreements* as the dominant policy response to this specific mismatch. Chapter 24's §24.5 difficult-terminology box already defined the mechanics of an outcomes-based managed entry agreement in general -- a price or refund tied to real-world performance rather than fixed at launch regardless of outcome -- and that same mechanism is the natural fit here: a payer agrees to reimburse a gene therapy's full list price up front, with a contractual commitment from the manufacturer to refund some or all of that payment (often on a sliding, time-based schedule) if the patient's disease relapses or the benefit is shown not to have lasted as long as assumed. This converts some of the durability risk from the payer's balance sheet back onto the manufacturer, who after all has the deepest insight into the clinical program and the most to gain from an optimistic durability assumption being right.

A second, complementary mechanism addresses the upfront-payment problem more directly rather than the durability-uncertainty problem: *annuity* or *staged-payment* models, where the payer spreads the single very large payment over several years of instalments -- commonly linked to continued evidence that the patient remains in remission or has not relapsed -- rather than paying the full amount in one lump sum at infusion. This does not reduce the manufacturer's total expected revenue in the way an outcomes-based refund can, but it does reduce the payer's single-year budget shock (directly relevant to the budget-impact mechanics of Chapter 23) and keeps some portion of each instalment contingent on evidence of continued benefit, giving it a partial outcomes-linkage flavour as well. In practice, the two mechanisms are often combined: staged payments with a refund or stop-payment trigger if relapse is confirmed before a given instalment is due.

#heor-practice[
  When a managed-entry or staged-payment agreement is genuinely under negotiation (rather than merely being described conceptually), keep the *contractual payment schedule* and the *underlying clinical durability model* as two separate, explicitly linked objects in the analysis rather than one hand-merged spreadsheet. The clinical model answers "how long does the cure actually last, and with what uncertainty?"; the payment schedule answers "given that answer, who pays what, and when?" Collapsing both into a single set of numbers makes it much harder to re-run the clinical question under a revised durability assumption without also having to re-derive the payment terms from scratch -- exactly the kind of parameterisation discipline argued for throughout Part VI.
]

The direct R-modelling implication follows from this: a Markov or other decision-model structure built for a curative gene or cell therapy must build in an explicit durability or waning-of-effect parameter, rather than defaulting to the structurally simpler assumption that once a patient enters a "cured" or "remission" state, they stay there with probability 1 for the rest of the model horizon. The shape of that waning curve -- does the hazard of relapse stay flat indefinitely, rise after some number of years as the first long-term data readouts start to show late relapses, or something else entirely -- is itself a major source of structural uncertainty, generally far larger than the usual parameter uncertainty captured by a probabilistic sensitivity analysis on a single fixed hazard value.

```r
# Illustrative, hypothetical durability/waning-of-effect parameterisation
# for a one-time gene therapy's "cured"/remission state. NOT real trial data.
library(dplyr)

cycles <- 0:40                      # 40 six-month cycles = 20 years
waning_start_cycle <- 10            # waning assumed to begin at year 5

# Three competing structural assumptions for the post-waning relapse hazard
durability_scenarios <- tibble::tibble(
  cycle = rep(cycles, times = 3),
  scenario = rep(c("durable_forever", "constant_waning", "accelerating_waning"),
                  each = length(cycles))
) %>%
  mutate(
    relapse_hazard = case_when(
      scenario == "durable_forever"                         ~ 0,
      scenario == "constant_waning" & cycle < waning_start_cycle   ~ 0,
      scenario == "constant_waning" & cycle >= waning_start_cycle  ~ 0.01,
      scenario == "accelerating_waning" & cycle < waning_start_cycle ~ 0,
      scenario == "accelerating_waning" & cycle >= waning_start_cycle ~
        0.005 * (cycle - waning_start_cycle + 1)
    )
  )

# Convert each scenario's hazard sequence into cumulative probability
# of remaining relapse-free by each cycle (discrete-time survival)
durability_scenarios <- durability_scenarios %>%
  group_by(scenario) %>%
  mutate(remain_relapse_free = cumprod(1 - relapse_hazard)) %>%
  ungroup()

durability_scenarios %>%
  filter(cycle %in% c(0, 10, 20, 30, 40)) %>%
  select(scenario, cycle, relapse_hazard, remain_relapse_free) %>%
  arrange(scenario, cycle)
```

Running this illustrative code shows the mechanical point plainly: by cycle 40 (20 years), the `durable_forever` scenario still has 100% of patients relapse-free by construction, while `constant_waning` and `accelerating_waning` -- using the same early trial-window data, which looks identical across all three scenarios for the first 10 cycles -- diverge substantially in their 20-year relapse-free proportion. A single-scenario base case silently picks one of these three futures; a defensible analysis runs all plausible waning-curve shapes as structural scenarios (not merely varying a single parameter's value within one fixed shape) and reports the cost-effectiveness conclusion's sensitivity to that structural choice explicitly, exactly as §32.1 recommended for immature survival-curve extrapolations in oncology.

== 32.7 Infectious diseases and TB: programmatic and cascade-of-care models

The book's running tuberculosis case study has, up to this point, been built and extended one modelling technique at a time: Chapter 17 resolved the regimen choice (4-month rifapentine-moxifloxacin, Study 31/A5349, versus the 6-month standard daily regimen) into a four-state Markov cohort structure; Chapter 19 turned that structure into a working cycle-by-cycle cost and QALY calculation; Chapter 22 extended the same TB example into a population-level SEIR compartmental transmission model via `deSolve::ode()` to evaluate a screening/preventive-therapy programme; Chapter 23 used a TB-adjacent budget-impact structure to show payer-facing affordability accounting; and Chapter 31 used the TB model's own verified base-case numbers to illustrate responding to an ERG's alternative-discount-rate request, alongside HTAIn's India-specific reference case. This section closes that running thread by introducing the specific conceptual framework that ties diagnosis, treatment, and population-level programme design together for TB and other infectious diseases: the *cascade of care*.

#difficult-terminology("Cascade of care")[
  The cascade of care is a sequential framework for tracking what actually happens to a population of people with a disease as they move -- or fail to move -- through the successive steps required to be cured: typically *diagnosis* (the person is identified as having the disease, via symptom-based presentation, active case-finding, or contact screening), *treatment initiation* (the diagnosed person actually starts the prescribed treatment regimen, which is not guaranteed even after a correct diagnosis), *treatment completion* (the person finishes the full course, which for TB can run four to six months or considerably longer for drug-resistant strains), and *cure* (confirmed resolution, usually via follow-up sputum or culture testing). The crucial feature of a cascade is that attrition -- patients falling out of care -- can happen at *any* of these steps, not only at the final one, and each step's attrition compounds with every step before it. A patient who never gets diagnosed cannot be treated no matter how effective the drug regimen is; a patient who is diagnosed but never starts treatment contributes zero cure benefit despite a seemingly successful diagnostic programme. The cascade framework is originally most associated with HIV care continuum modelling but is now a standard analytic lens across TB, hepatitis C, and other chronic infectious diseases where multi-step attrition, not treatment efficacy alone, often explains most of the gap between a programme's theoretical and actual population-level impact.
]

This is the missing piece that connects Chapter 17-19's patient-level Markov model to Chapter 22's population-level transmission model: the Markov model in Chapters 17-19 implicitly assumed every simulated patient had already successfully reached the "On Treatment" state -- it modelled what happens *after* diagnosis and treatment initiation, not the real-world attrition that happens *getting there*. A fully programmatic TB model needs an explicit cascade stage sitting in front of that Markov structure, because in many high-burden settings a meaningful fraction of people with active TB are never diagnosed at all, and a meaningful further fraction of those who are diagnosed never actually start treatment -- both losses that a model starting its clock at "On Treatment" simply cannot see.

Programmatic, population-level TB modelling differs from a single-patient cohort model in a second important way: it has to represent heterogeneity in the *organism*, not only the patient. Drug-resistant TB strains -- multidrug-resistant (MDR-TB) and the rarer, harder-to-treat extensively drug-resistant (XDR-TB) -- require longer, more toxic, and far more expensive treatment regimens, and a population-level model needs to track the proportion of incident cases that are drug-resistant explicitly (often as a separate compartment or a separate cohort entirely) rather than applying one average regimen cost and cure probability across the whole TB-positive population. It also has to represent heterogeneity in *adherence*: TB treatment's long duration makes incomplete adherence a major real-world driver of both relapse and the emergence of resistance, which is precisely why the WHO-promoted *DOTS* strategy became the cornerstone of global TB control programmes for decades.

#difficult-terminology("DOTS (directly observed treatment, short-course)")[
  DOTS is a WHO-promoted TB control strategy in which a healthcare worker, community volunteer, or in some modern implementations a digital video-observation tool, directly observes the patient swallowing each dose of their TB medication, for the full course of treatment. The rationale is adherence assurance: because an incomplete TB treatment course both risks relapse for the individual patient and risks selecting for drug-resistant bacterial strains that can then spread to others, direct observation was adopted as a core structural safeguard rather than relying solely on patient self-report. DOTS was the organising principle of the WHO's TB control strategy from the 1990s onward and remains a foundational historical and operational reference point even as some national programmes have since moved toward more flexible, patient-centred adherence-support models (including digitally-enabled observation) that relax the strict requirement for in-person observation of every single dose.
]

The global policy framework that this kind of cascade-and-programme modelling typically supports is the WHO's *End TB Strategy*, adopted in 2014 and built around three pillars: (1) integrated, patient-centred care and prevention -- covering early diagnosis, treatment of all people with TB including drug-resistant TB, TB/HIV collaborative activities, and preventive treatment of high-risk groups; (2) bold policies and supportive systems -- political commitment, community engagement, universal health coverage, and social protection against the catastrophic costs TB can impose on affected households; and (3) intensified research and innovation. A programmatic R model built around a cascade-of-care structure, feeding into a transmission model of the kind built in Chapter 22, is exactly the analytic tool a national TB programme or a funder such as the Global Fund would use to ask End TB Strategy-relevant questions: which stage of the cascade, if strengthened, would avert the most future TB cases and deaths per dollar spent -- more active case-finding to improve diagnosis, better linkage-to-care support to improve treatment initiation, or stronger adherence support (DOTS-style or otherwise) to improve treatment completion?

#heor-practice[
  When extending Chapter 19's four-state TB Markov model (On Treatment, Cured, Treatment Failure, Death) into a full programmatic cascade, resist folding diagnosis and linkage-to-care attrition into the existing "On Treatment" transition probabilities as a hidden adjustment factor. Keep diagnosis probability, treatment-initiation probability (conditional on diagnosis), and the existing Chapter 19 treatment-outcome probabilities (conditional on initiation) as three separate, clearly labelled parameters. This is the same discipline Chapter 31's §31.6 applied to discount rate and Chapter 23 applied to acquisition-versus-offset cost reporting: a reviewer -- or a later analyst reusing the model for a different country's cascade data -- needs to see and challenge each stage independently, not reverse-engineer which real-world loss a single blended number is meant to represent.
]

The following R example builds exactly that missing front-end: a simple multiplicative cascade-of-care attrition calculation that sits upstream of (and could feed directly into) the Chapter 19 Markov cohort's starting distribution, rather than assuming the whole simulated cohort starts in the "On Treatment" state with probability 1.

```r
# Illustrative TB cascade-of-care attrition, feeding a Markov cohort's
# starting distribution. Stage probabilities are hypothetical/illustrative,
# not real country-level TB programme data.
library(dplyr)

cascade <- tibble::tibble(
  stage = c("symptomatic_presumptive_tb",
            "diagnosed",
            "initiated_treatment",
            "completed_treatment",
            "bacteriologically_cured"),
  # Probability of REACHING this stage, CONDITIONAL on having reached
  # the previous stage -- not an absolute population-level probability.
  conditional_prob = c(1.00,   # everyone starts as presumptive (by definition)
                        0.70,  # 70% of presumptive TB cases get correctly diagnosed
                        0.85,  # 85% of those diagnosed actually start treatment
                        0.80,  # 80% of those who start complete the full course
                        0.90)  # 90% of completers are confirmed bacteriologically cured
) %>%
  mutate(cumulative_prob = cumprod(conditional_prob))

cascade
```

For a hypothetical cohort of 10,000 people with presumptive TB entering this cascade, running the code above shows the cumulative attrition compounding stage by stage: roughly 7,000 reach diagnosis, roughly 5,950 initiate treatment, roughly 4,760 complete treatment, and roughly 4,284 are ultimately confirmed cured -- a population-level cure rate of about 42.8%, even though the single worst individual stage-conditional probability (diagnosis, at 70%) might on its own look like the obvious target for improvement. The compounding effect is the real lesson: a 10-percentage-point improvement at any one stage changes the final cured proportion by a different amount depending on which stage it is applied to and how much attrition has already occurred upstream, which is exactly the kind of question a programmatic cascade model, linked to the transmission dynamics of Chapter 22, is built to answer quantitatively rather than by intuition.

#report-table(
  [Illustrative TB cascade-of-care attrition for a hypothetical cohort of 10,000 presumptive TB cases, computed from the stage-conditional probabilities above.],
  academic-table(
    columns: (1.8fr, 1fr, 1fr, 1.2fr),
    align: (left, right, right, right),
    header: ([*Cascade stage*], [*Cond. prob.*], [*Cum. prob.*], [*Remaining (of 10,000)*]),
    body: (
      [Presumptive TB], [1.00], [1.000], [10,000],
      [Diagnosed], [0.70], [0.700], [7,000],
      [Initiated treatment], [0.85], [0.595], [5,950],
      [Completed treatment], [0.80], [0.476], [4,760],
      [Bacteriologically cured], [0.90], [0.428], [4,284],
    ),
    footer: (table.cell(colspan: 4)[Illustrative/hypothetical stage probabilities, not real programme data.],),
  ),
) <tab-ch32-tb-cascade>

== 32.8 Health systems modelling and resource allocation

Every chapter so far in this book -- and every subsection before this one in Chapter 32 -- has asked, implicitly, a one-technology question: is *this* drug, *this* device, *this* diagnostic, *this* gene therapy worth its price relative to its own specific comparator? That framing is necessary but incomplete, because real health systems do not make decisions about one technology in isolation. They operate under a fixed, or at best slowly-growing, total budget, and every "yes" decision for one technology is a "no" (or a "less") for something else that budget could otherwise have funded.

Chapter 26's value-of-information framing already introduced the underlying economic logic of this: a cost-effectiveness threshold is, properly understood, an estimate of the health forgone elsewhere in the system when money is spent on a new technology -- an *opportunity cost*, not an arbitrary affordability line. Zooming out from a single-technology appraisal to the health-system level simply takes that same opportunity-cost logic and applies it explicitly across *many* competing claims on the same budget at once, rather than implicitly, one appraisal at a time, through a threshold that was itself estimated from system-wide evidence.

This is the territory of *portfolio-level* or *multi-criteria resource allocation*: instead of asking "does Drug X beat its comparator at an acceptable ICER," the question becomes "given a fixed total budget, which combination of programmes -- a new drug, an expanded screening programme, a public health campaign, additional TB diagnostic capacity -- delivers the most total health (or value, under whatever multi-criteria weighting a system has adopted, echoing Chapter 24's MCDA and EVIDEM material) across the whole portfolio of options competing for that same money?" Chapter 24's multi-criteria decision analysis machinery is directly relevant here, but applied across programmes competing for one budget line rather than within a single appraisal comparing one technology's dimensions of value.

In R terms, this usually looks less like a single cost-effectiveness model and more like a constrained optimisation or ranking exercise layered on top of several already-built single-technology models: taking each candidate programme's estimated incremental cost and incremental health benefit (the same outputs Chapters 17-24 already know how to produce) and solving for the combination that maximises total health gained subject to the fixed budget constraint -- a programme budgeting and marginal analysis (PBMA) exercise, in the language some health systems use for this specific activity.

It is worth being honest about where this chapter's -- and this book's -- depth genuinely runs out. A full whole-system simulation that captures interacting resource constraints across multiple diseases and programmes simultaneously (shared diagnostic laboratory capacity, shared clinical workforce, shared hospital bed capacity, competing budget lines across an entire ministry of health) is a substantially more advanced undertaking than anything built in Chapters 17-23, closer to the territory of *system dynamics* modelling or large-scale whole-health-system simulation than to the single-disease decision-analytic and transmission models this book has focused on. That is a genuinely different, more advanced modelling discipline, and this book has deliberately stayed within the single-technology and single-disease (including the TB case study's population-level extension in Chapter 22) scope throughout -- readers who need to go further into true whole-system resource-allocation modelling should treat this subsection as a signpost toward that literature rather than a worked introduction to it.

#agency-note[
  Several health systems have built or commissioned explicit portfolio-level priority-setting processes rather than leaving this entirely implicit in a series of independent single-technology appraisals -- South Africa's and other countries' use of programme budgeting and marginal analysis (PBMA) exercises, and WHO's broader work on priority-setting institutions for universal health coverage, are genuine real-world examples of systems trying to make the opportunity-cost tradeoff explicit across competing programmes rather than leaving it buried inside a single cost-effectiveness threshold. Confirm the specific process and current status directly with the relevant ministry or agency before citing one as a precedent in any real analysis -- these institutional arrangements vary considerably by country and change over time.
]

That zooming-out from a single technology's value to the whole system's allocation of a fixed budget is also a fitting place to close this chapter. Chapter 32 has moved through a deliberately varied set of special cases -- oncology's immature survival curves, orphan drugs and rare-disease evidence standards, vaccines, diagnostics, digital health and AI, gene and cell therapies, and TB's programmatic cascade -- each stretching the standard single-technology HTA toolkit in its own direction. But every one of those special cases still ultimately feeds into the same system-level resource-allocation question this section has just raised: once a technology clears its own cost-effectiveness bar, it still has to compete for a place in a finite budget alongside everything else that also clears that bar. The chapters immediately ahead turn to a different kind of input into all of these decisions -- not how a technology's value is modelled, but how the outcomes that feed every one of these models are actually measured from the patient's own perspective. Chapter 33 picks up exactly there, with patient-reported outcomes and preference research.
