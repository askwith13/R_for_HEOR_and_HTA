#import "../common.typ": *

= Chapter 33. Patient-Reported Outcomes and Preference Research

#learning-objectives((
  [Explain why patient-reported outcome (PRO) instrument validation matters for HTA, and distinguish classical test theory reliability statistics from confirmatory factor analysis and item response theory.],
  [Fit a confirmatory factor analysis with lavaan::cfa() and an item response theory model with mirt::mirt() to simulated PRO item data, and interpret factor loadings, fit indices, and item parameters.],
  [Distinguish a Minimal Clinically Important Difference (MCID) from statistical significance, and compare anchor-based and distribution-based MCID estimation methods.],
  [Apply an MCID threshold to define treatment responders in an economic model structure, and justify that threshold's provenance for an HTA submission.],
  [Explain discrete choice experiments (DCEs), random utility theory, and the conditional/mixed logit models used to analyse them, and describe the relative positioning of mlogit, apollo, and logitr.],
  [Distinguish best-worst scaling's three cases from a standard DCE, and situate both within the broader conjoint-analysis family of preference-elicitation methods.],
  [Evaluate the stated-versus-revealed-preference limitation of DCE/BWS evidence when it feeds into HTA decision-making.],
))

== 33.1 PRO analysis and psychometrics in R (`lavaan`, `mirt`)

Every economic model in this book eventually asks a very human question: how much is a given health state worth to the people who actually live in it? Chapter 8 showed how that question gets answered with utility values -- numbers between 0 (dead) and 1 (full health) that feed straight into the QALY calculation. But those utility values do not appear from nowhere. They are built, directly or indirectly, from *patient-reported outcome* (PRO) measures: structured questionnaires in which patients themselves rate their health, symptoms, functioning, or quality of life. The EQ-5D asks patients to rate five dimensions of health and converts the result into a utility index via a value set; the SF-36 and its shorter relatives summarise physical and mental health across eight domains; hundreds of disease-specific instruments ask about things a generic measure cannot capture -- breathlessness in COPD, itch in eczema, fatigue in cancer. Whatever the model later does with a utility value, a treatment effect, or a responder rate, that number traces back to a patient filling in a questionnaire. If the questionnaire itself is not measuring what it claims to measure, everything built on top of it inherits that flaw.

This is why HTA bodies care, often quite intensely, about the *measurement properties* of PRO instruments, not just the clinical results that come out of them. A trial can be impeccably randomised and still produce a PRO endpoint that nobody should trust, if the instrument behind it conflates two unrelated constructs, or if a subset of items simply does not behave the way the scoring algorithm assumes. Psychometrics -- the discipline of quantifying the properties of psychological and health measurement instruments -- exists to catch exactly this kind of problem before (ideally long before) a dossier reaches a reimbursement committee.

#agency-note[
  The FDA's 2009 guidance *"Patient-Reported Outcome Measures: Use in Medical Product Development to Support Labeling Claims"* (Docket FDA-2006-D-0362) is the single most influential regulatory document shaping how PRO instruments are expected to be developed and validated for use in supporting a labeling claim. It sets out, among other requirements, that sponsors document an instrument's *conceptual framework* and *content validity* (evidence the instrument measures what it claims to, gathered via patient interviews and focus groups, not just statistical fit), that measurement properties be well established before a confirmatory trial begins, and that sponsors avoid proposing labeling claims based on statistical significance alone -- a direct regulatory echo of the MCID distinction covered in the next section. HTA bodies reviewing a PRO-based submission routinely expect this same standard of documented instrument development, whether or not the submission also went through FDA review.
]

=== Classical test theory: reliability and internal consistency

The oldest and still most widely reported psychometric framework is *classical test theory* (CTT). CTT treats every observed score as a noisy measurement of a true, unobserved score: $"observed" = "true" + "error"$. A central question under CTT is *reliability*: if you repeated the measurement, how consistent would the result be? One practical way to probe reliability without actually re-testing anyone is to ask whether the individual items of a multi-item scale "agree" with each other -- this is *internal consistency*, and its most common summary statistic is Cronbach's alpha.

#difficult-terminology("Cronbach's alpha")[
A single number, typically between 0 and 1, summarising how closely a set of items on a scale move together across respondents. Loosely: if you have eight items that are all supposed to measure "fatigue," and patients who score high on one fatigue item tend to score high on all the others, alpha will be close to 1. If the items are measuring unrelated things, alpha will be low even though each item individually might look fine. A common rule of thumb treats alpha above roughly 0.70 as acceptable for group-level comparisons and above roughly 0.90 as needed for decisions about individual patients -- though treating these cutoffs as hard thresholds, rather than context-dependent guides, is itself a frequent and avoidable overinterpretation. Alpha is not a measure of whether the items measure the *right* construct, only of whether they move together; a scale can have high alpha and still be measuring the wrong thing entirely.
]

CTT reliability statistics are cheap to compute and easy to report, which is why they appear in almost every PRO validation paper. But CTT has a structural limitation that matters a great deal for health measurement: it treats the instrument, not the individual item, as the unit of analysis, and it implicitly assumes every respondent has effectively taken the same test under the same conditions. Neither assumption holds well when instruments differ in difficulty across patient subgroups, or when (as is increasingly common) different patients answer different subsets of items, as in computer-adaptive testing. Two more modern frameworks address these gaps from different angles: confirmatory factor analysis, which asks whether the *structure* of an instrument is correct, and item response theory, which models each *item* on its own terms.

=== Confirmatory factor analysis with `lavaan`

A PRO instrument is usually designed around one or more *latent constructs* -- unobservable things like "physical functioning" or "anxiety" that cannot be measured directly, only inferred from how patients answer a set of observed items. *Confirmatory factor analysis* (CFA) tests a specific, pre-specified hypothesis about that structure: does a proposed set of items really load onto the latent factor(s) the instrument's developers intended, in the pattern they intended, and not some other pattern?

#difficult-terminology("confirmatory factor analysis (CFA)")[
A statistical technique that checks whether a hypothesised measurement structure fits the way patients actually answered a questionnaire. You specify in advance which items are supposed to measure which latent (unmeasured) factor -- for example, "items 1 through 4 all measure *physical function*; items 5 through 7 all measure *emotional wellbeing*" -- and CFA tests how well real response data support that specific structure, rather than discovering a structure from scratch (that discovery exercise is a *different*, related technique called exploratory factor analysis). Think of it as presenting a blueprint and asking "does the building that was actually constructed match this blueprint?", rather than wandering around an unfamiliar building trying to guess its floor plan.
]

In R, the `lavaan` package is the standard tool for fitting CFA models. Model structure is expressed with a compact formula syntax in which `=~` means "is measured by" -- read `factor =~ item1 + item2 + item3` as "this latent factor is measured by these observed items." The workhorse function is `lavaan::cfa()`, which takes the model syntax and a data frame of the observed items.

The example below simulates a small, six-item questionnaire intended to measure two latent constructs -- call them "physical symptom burden" and "emotional distress" -- each measured by three Likert-scale items, and then fits a two-factor CFA to check whether the hypothesised structure is supported.

```r
library(lavaan)

set.seed(42)
n <- 300

# Two latent factors driving six observed Likert items (1-5 scale)
physical_f  <- rnorm(n)
emotional_f <- rnorm(n)

sim_item <- function(loading, factor_scores, noise_sd = 0.6) {
  raw <- loading * factor_scores + rnorm(n, sd = noise_sd)
  # discretise onto a 1-5 Likert scale
  pmin(pmax(round(raw + 3), 1), 5)
}

pro_data <- data.frame(
  p1 = sim_item(0.9, physical_f),
  p2 = sim_item(0.8, physical_f),
  p3 = sim_item(0.7, physical_f),
  e1 = sim_item(0.85, emotional_f),
  e2 = sim_item(0.75, emotional_f),
  e3 = sim_item(0.65, emotional_f)
)

# Hypothesised two-factor measurement model
pro_model <- '
  physical  =~ p1 + p2 + p3
  emotional =~ e1 + e2 + e3
'

fit <- cfa(model = pro_model, data = pro_data)
summary(fit, fit.measures = TRUE, standardized = TRUE)
```

The `summary()` call reports standardised factor loadings (how strongly each item relates to its intended factor -- values well above roughly 0.5-0.6 are generally reassuring) alongside global fit indices such as the comparative fit index (CFI) and root mean square error of approximation (RMSEA), which indicate whether the hypothesised two-factor structure as a whole is a plausible description of the data, as opposed to a structure the analyst merely hoped for. A well-validated PRO instrument used in an HTA submission should have published CFA results of exactly this kind, usually from the instrument's original validation study or a disease-specific adaptation study, not generated for the first time inside the economic model.

=== Item response theory with `mirt`

Item response theory (IRT) approaches the same underlying problem -- does this instrument measure what it claims to measure, and how well -- from the item's perspective rather than the whole-scale perspective.

#difficult-terminology("Item Response Theory (IRT)")[
A family of statistical models that describe the probability of a particular response to a particular item as a function of (a) the respondent's underlying level of the trait being measured (their "ability" or severity) and (b) properties of that specific item, most commonly its *difficulty* (where on the trait scale the item is most informative) and its *discrimination* (how sharply the item distinguishes respondents just above that point from those just below). Unlike classical test theory, which produces one reliability number for the whole scale, IRT estimates parameters for each item individually. This has two very practical consequences for PRO measurement. First, it tells you which items are doing the most work and which add little. Second, because every item's parameters live on the same underlying scale, IRT makes it statistically defensible for different patients to answer different subsets of items -- the basis of *computer-adaptive testing*, where a computer selects each patient's next question based on their previous answers, shortening the questionnaire without sacrificing measurement precision. The U.S. NIH's PROMIS instrument system is a widely used example built on this logic.
]

The `mirt` package fits these models in R. Its central function, `mirt::mirt()`, takes a data frame or matrix of item responses, the number of latent dimensions (or a more detailed model specification), and an `itemtype` argument specifying the response model for each item -- for example `"2PL"` for binary items with both difficulty and discrimination parameters, or `"graded"` for ordinal (Likert-style) items using Samejima's graded response model.

```r
library(mirt)

set.seed(7)
n <- 400
n_items <- 5

# One latent trait ("mobility limitation") with items of varying
# difficulty and discrimination, generating binary (yes/no) responses
theta        <- rnorm(n)
difficulty   <- c(-1.5, -0.5, 0, 0.5, 1.5)
discrim      <- c(0.8, 1.2, 1.5, 1.0, 0.9)

binary_items <- sapply(seq_len(n_items), function(j) {
  p <- plogis(discrim[j] * (theta - difficulty[j]))
  rbinom(n, 1, p)
})
colnames(binary_items) <- paste0("item", seq_len(n_items))

irt_fit <- mirt(data = as.data.frame(binary_items), model = 1,
                 itemtype = "2PL")

coef(irt_fit, simplify = TRUE)
itemplot(irt_fit, item = 1)
```

`coef()` returns the estimated discrimination (`a`) and difficulty-related (`d`) parameters for each item, and `itemplot()` draws the item characteristic curve -- the probability of a positive response as a function of the latent trait. Items with low discrimination are flagged as weak measurement instruments regardless of how plausible they sounded when the questionnaire was drafted.

#heor-practice[
CTT reliability statistics, CFA, and IRT are not mutually exclusive techniques competing for the analyst's favour -- a mature PRO validation programme typically reports all three. Internal consistency statistics give a quick, familiar summary; CFA confirms the instrument's intended factor structure holds in the population it is being used in; IRT characterises individual item performance and supports any adaptive or short-form administration. When reading a clinical-outcomes assessment dossier or an instrument's user manual, look for all three strands rather than assuming a high Cronbach's alpha alone settles the question.
]

#pitfall[
Fitting `cfa()` or `mirt()` on a handful of ad hoc items invented for a single trial is not the same exercise as validating a PRO instrument. Genuine PRO validation is a substantial, multi-study undertaking: it typically involves qualitative work with patients to establish content validity (do the items cover what matters to patients, in their own words?), large and often multiple independent samples to confirm factor structure and item parameters are stable, and formal assessment of other measurement properties such as test-retest reliability, responsiveness to change, and measurement invariance across languages or subgroups. A sponsor that writes three or four Likert questions specifically for one trial, runs a quick internal-consistency check, and then treats the resulting score as an established, clinically meaningful PRO endpoint is skipping essentially all of this work. HTA reviewers are alert to exactly this shortcut, and an outcome measure without a genuine, published validation history will routinely be challenged or discounted in an appraisal, however statistically tidy the trial-specific analysis looks.
]

== 33.2 Minimal clinically important differences

A PRO score moving from a baseline value to a follow-up value is, on its own, just a number. Chapter 33.1 was concerned with whether the number is being measured correctly at all. This section asks a different, equally important question: once you trust the measurement, how large a change actually *matters* to a patient? The answer is not automatically "any change with a small p-value."

#difficult-terminology("Minimal Clinically Important Difference (MCID)")[
The smallest change in a score -- on a PRO instrument or another clinical outcome measure -- that patients or clinicians would recognise as meaningful, as opposed to a change that is merely detectable by a statistical test. (The terms *MCID* and *MID*, for minimal important difference, are used largely interchangeably in the literature.) The distinction from statistical significance is genuinely important and easy to miss: statistical significance is a property of the *evidence* -- it tells you how confident you can be that the true change is not exactly zero, and with a large enough sample, even a tiny, clinically irrelevant average change can become "significant." Clinical importance is a property of the *size* of the change itself, independent of how confidently it was measured. An analogy: imagine a very precise bathroom scale that can reliably detect a 50-gram change in body weight across thousands of repeated measurements. That the 50-gram change is statistically real does not make it a clinically important change in body weight -- nobody would notice or care about 50 grams. Conversely, a genuinely important 5 kg weight change could fail to reach statistical significance in a trial with only twenty participants, simply because the sample was too small to pin the estimate down precisely. A trial result can therefore be statistically significant but clinically trivial, or clinically important but statistically non-significant -- the two properties are related only through sample size and effect size, not identical to each other.
]

This distinction is not an academic nicety. A moderately sized trial can report a PRO improvement with a reassuringly small p-value while the actual magnitude of improvement -- say, two points on a 100-point quality-of-life scale -- is far below anything a patient would notice in daily life. An HTA committee relying on the p-value alone could be misled into treating a clinically negligible effect as a meaningful clinical benefit. MCID thresholds exist specifically to anchor interpretation of PRO results to something closer to patient experience.

=== Estimating an MCID: anchor-based and distribution-based methods

Two broad families of methods are used to estimate an MCID for a given instrument and population.

#difficult-terminology("anchor-based method")[
An approach to estimating an MCID that compares the change in a PRO score against an independent, external indicator ("anchor") of whether the patient's condition genuinely changed by a clinically meaningful amount. The most common anchor is a patient global rating of change scale, where patients are asked directly, in their own words, something like "compared to before, has your condition got much better, a little better, stayed the same, a little worse, or much worse?" The average PRO score change among patients who selected "a little better" (or an equivalent small-but-real external indicator, such as a clinician's independent global assessment) becomes the estimated MCID. Because the anchor is a genuinely external signal of what patients themselves consider meaningful, anchor-based estimates are generally considered the stronger, more clinically grounded form of evidence.
]

#difficult-terminology("distribution-based method")[
An approach to estimating an MCID using only the statistical properties of the scale itself -- most commonly a fraction of the scale's baseline standard deviation (half a standard deviation, $0.5 times "SD"$, is a widely cited convention attributed to Norman, Sloan, and Wyrwich) or the standard error of measurement derived from the instrument's reliability. These methods are quick to compute from existing trial data and need no additional patient input, which explains their popularity -- but they are purely statistical proxies. A distribution-based threshold describes how variable or how reliable the scale is, not whether a given amount of change feels meaningful to a patient. Two instruments with identical statistical variability could have very different true clinical meaningfulness thresholds, and a distribution-based method cannot tell the difference between them. For this reason distribution-based estimates are generally treated as a fallback, used when anchor data are unavailable, rather than a preferred source of evidence.
]

The two families are often reported together and compared, since neither is considered definitive on its own; agencies and methods guidance generally favour anchor-based estimates where feasible precisely because they tie the threshold back to something patients themselves report as meaningful, with distribution-based figures serving as supporting or sensitivity evidence.

=== Why MCID matters for HTA and economic modelling

An economic model built from a trial's PRO data is only as informative as the interpretation attached to the PRO result feeding it. Two places this plays out directly:

- *Translating PRO change into utility change.* A trial PRO result reported as "statistically significant" tells a modeller nothing by itself about whether the health-state utility mapped from that score (Chapter 8) moved by an amount that matters. A model that quietly assumes any statistically detected PRO improvement corresponds to a meaningful utility gain risks overstating the treatment's value; checking the observed change against a published MCID for that instrument is a basic sanity check before that translation is made.
- *Defining a "responder" in model structure.* Many economic model structures -- especially those built around discrete health states rather than a continuous utility trajectory -- classify patients as "responders" or "non-responders" based on whether their PRO change exceeds a threshold, and that threshold is often drawn directly from a published MCID. The choice of threshold is therefore not a cosmetic modelling detail; a model is only as credible as the clinical meaningfulness of the threshold defining its states.

#agency-note[
Methods guidance from HTA and regulatory bodies increasingly expects a stated, justified basis for any responder definition or clinically meaningful threshold used in a submission, rather than an unexplained round number. When an MCID is anchor-based and drawn from a peer-reviewed validation study in a comparable population, that justification is usually straightforward to defend. When a submission instead reaches for a generic half-standard-deviation rule with no anchor-based support, reviewers are increasingly likely to ask for the anchor-based evidence, or to treat the distribution-based figure as provisional pending it.
]

=== A simple distribution-based MCID and responder analysis in R

The following example computes a conventional distribution-based threshold -- half the baseline standard deviation -- for a simulated PRO outcome, and then runs a basic responder analysis reporting the proportion of patients in a treatment arm whose individual change exceeds that threshold.

```r
set.seed(123)
n <- 200

# Simulated baseline and follow-up PRO scores (e.g. a 0-100 symptom scale,
# higher is better) for a treatment arm
baseline  <- rnorm(n, mean = 55, sd = 12)
treatment_effect <- rnorm(n, mean = 6, sd = 10)  # patient-level change
follow_up <- baseline + treatment_effect

pro_df <- data.frame(baseline = baseline, follow_up = follow_up)
pro_df$change <- pro_df$follow_up - pro_df$baseline

# Distribution-based MCID: 0.5 x baseline SD
baseline_sd <- sd(pro_df$baseline)
mcid_distribution <- 0.5 * baseline_sd
cat(sprintf("Distribution-based MCID estimate: %.2f points\n", mcid_distribution))

# Responder analysis: proportion of patients exceeding the MCID threshold
pro_df$responder <- pro_df$change >= mcid_distribution
responder_rate <- mean(pro_df$responder)
cat(sprintf("Responder rate (change >= MCID): %.1f%%\n", responder_rate * 100))
```

#report-table(
  [Illustrative responder analysis using a distribution-based MCID threshold ($0.5 times$ baseline SD) on the simulated treatment-arm data above.],
  academic-table(
    columns: (2fr, 1fr),
    align: (left, right),
    header: ([*Quantity*], [*Value*]),
    body: (
      [Baseline SD], [11.32 points],
      [Distribution-based MCID (0.5 x SD)], [5.66 points],
      [Mean observed change], [6.42 points],
      [Responder rate (change >= MCID)], [52.0%],
    ),
    footer: (table.cell(colspan: 2)[Illustrative simulated data; a real submission would substitute a published, ideally anchor-based, MCID for this instrument and population rather than a distribution-based proxy alone.],),
  ),
) <tab-ch33-mcid-responder>

The responder rate above is deliberately close to half -- a reminder that with an average treatment effect set almost exactly at the MCID threshold, the specific choice of threshold is doing a great deal of work in determining how good the treatment looks in a responder-based model structure. Changing the threshold by even a small, defensible amount can shift the reported responder rate substantially, which is precisely why the threshold's provenance -- anchor-based evidence from a credible source, rather than an unexamined statistical convention -- deserves as much scrutiny in an HTA submission as the trial's p-values.

== 33.3 Discrete choice experiments (`mlogit`, `apollo`, `logitr`)

Having established how PRO instruments are built, validated, and scored in the preceding sections, we now turn to a related but conceptually distinct family of tools: methods that elicit *preferences* rather than *experience*. Where a PRO instrument asks "how much pain are you in today?", a preference-elicitation study asks "how much pain would you be willing to tolerate in exchange for avoiding a weekly injection?" Both approaches start from patient-reported data, but preference methods are built to quantify trade-offs, and the discrete choice experiment (DCE) is the dominant tool for doing so in modern HTA.

A discrete choice experiment is a stated-preference survey method. Respondents are shown a series of choice tasks, each presenting two or more hypothetical alternatives -- most commonly competing treatment profiles -- that differ systematically across a small set of attributes: efficacy, risk of a specific side effect, dosing frequency, mode of administration, out-of-pocket cost, and so on. For each task the respondent simply picks the alternative they prefer. Repeated many times, with the attribute levels varied according to an experimental design, these choices reveal how much weight respondents implicitly place on each attribute relative to the others -- including, when cost is one of the attributes, a monetary willingness-to-pay figure for a one-unit change in any other attribute.

Chapter 8's §8.6 already introduced random utility theory (McFadden) in the context of discrete choice experiments used to elicit health-state utility values directly; the same statistical foundation applies here, now put to work eliciting preferences over treatment attributes rather than health states. As a quick recap: each respondent is assumed to have a true, fixed "utility" for every alternative shown, always picking the alternative with the higher utility; the "random" part is not that people choose randomly, but an acknowledgement that the analyst can never observe utility directly -- only the choice -- so utility is split into a systematic part explained by the measured attributes and a random error part capturing everything unmeasured. The error distribution assumption (typically a type I extreme value / Gumbel distribution) is what gives rise to the logit model described below.

The workhorse statistical model for analysing DCE data is the *conditional logit model* (sometimes called multinomial logit in this context, though the two terms are used slightly differently across fields). It estimates one coefficient per attribute, representing the contribution of that attribute to overall utility, under the random-utility assumptions above. These coefficients are the raw "part-worths" from which relative attribute importance and, when a cost attribute is included, willingness-to-pay ratios are derived. The conditional logit's major simplifying assumption is that every respondent weighs each attribute identically -- an assumption that is often unrealistic in patient populations where, for example, risk tolerance for a side effect genuinely differs between individuals.

#difficult-terminology("mixed logit model")[
  A mixed logit model (also called a random-parameters logit) relaxes the "everyone has the same preferences" assumption of the standard conditional logit. Instead of estimating a single coefficient for, say, "risk of nausea," it estimates a *distribution* of coefficients across the respondent population -- a mean effect plus a measure of how much that effect varies from person to person. Practically, this means the model can tell you not just "on average, patients dislike nausea risk" but "some patients barely mind it, while others are strongly averse to it," which is often closer to clinical reality and more useful for understanding subgroup heterogeneity than a single average weight.
]

Three R packages are commonly used for DCE analysis, and they occupy genuinely different niches rather than being interchangeable:

- *`mlogit`* is the long-established, foundational package for estimating conditional and multinomial logit models in R. It has the longest track record, broad documentation, and is often the first package analysts reach for when the model is a standard conditional or mixed logit without unusual structure.
- *`apollo`* is a more recent and considerably more flexible package aimed at complex choice-model structures -- including hybrid choice models that combine latent psychological constructs with observed choices, and latent-class models that let the analyst identify discrete preference segments within the sample rather than (or in addition to) a continuous mixing distribution. The added flexibility comes with a steeper learning curve and more explicit model specification than `mlogit`.
- *`logitr`* is a newer, more streamlined package focused specifically on multinomial and mixed logit models estimated in either "preference space" (coefficients scaled in utility units) or "WTP space" (coefficients scaled directly in willingness-to-pay/monetary units), which is convenient when the main analytic output needed is a WTP estimate with its own standard error, rather than a utility coefficient that has to be converted afterward.

None of these packages is strictly superior; the choice depends on whether the priority is an established, widely-cited workhorse (`mlogit`), the ability to fit non-standard model structures (`apollo`), or a clean, WTP-space-native workflow for a fairly standard mixed logit (`logitr`).

Before any of these packages can be used, the raw survey responses have to be reshaped into the "long" format that choice models expect: one row per alternative, per choice task, per respondent, with a column for each attribute and an indicator for whether that particular alternative was the one chosen.

```r
# Illustrative structure of a DCE dataset in long format.
# One row per alternative shown within each choice task, for each respondent.
# (Real coefficient estimates would come from fitting mlogit, apollo, or
#  logitr to actual survey data -- not shown here.)

dce_long <- data.frame(
  respondent_id = c(1, 1, 2, 2, 2, 2),
  choice_task    = c(1, 1, 1, 1, 2, 2),
  alternative    = c("A", "B", "A", "B", "A", "B"),
  efficacy_pct   = c(70, 55, 70, 55, 85, 60),
  side_effect_risk = c("moderate", "low", "moderate", "low", "high", "low"),
  dosing_freq    = c("weekly", "daily", "weekly", "daily", "daily", "weekly"),
  monthly_cost   = c(150, 90, 150, 90, 220, 110),
  chosen         = c(1, 0, 0, 1, 1, 0)
)
```

Each `choice_task` groups the alternatives a respondent compared side by side; `chosen` is 1 for the alternative actually picked and 0 for the rest. It is this structure -- attribute columns varying systematically alongside a binary chosen/not-chosen outcome -- that `mlogit::mlogit()`, `apollo`'s estimation routines, or `logitr::logitr()` take as their starting input once properly formatted for each package's expected data object.

== 33.4 Best-worst scaling and conjoint analysis

A close relative of the DCE is *best-worst scaling* (BWS). Rather than (or sometimes in addition to) choosing a single most-preferred alternative, respondents in a BWS task are shown a set of items or attribute-levels together and asked to identify both the *best* and the *worst* of the set. Forcing a worst-choice judgement alongside a best-choice one is a deliberate design feature: it pushes respondents to make genuine discriminating trade-offs across the full set rather than, say, rating every item a "5 out of 5" on a Likert scale out of politeness or inattention -- a response pattern (sometimes called a ceiling-effect or scale-use bias) that plain rating scales are notoriously prone to.

#difficult-terminology("best-worst scaling")[
  Best-worst scaling is easiest to picture by contrast with a simple rating task. If you ask someone to rate five symptoms on a 1-5 bothersomeness scale, they might rate several a "5" if several genuinely bother them a lot, giving you little information about which matters *most*. If instead you show them the same five symptoms together and ask "which bothers you most, and which bothers you least," you force a direct comparison that reveals relative ranking information even when absolute intensities are similar. Repeating this across multiple, systematically varied subsets of items (or attribute-levels) lets the analyst statistically reconstruct a full preference ordering, using logit-family models closely related to those used for DCEs.
]

BWS methodology is conventionally described in terms of three recognized "cases," distinguished by what exactly is being scaled:

- *Case 1 (object scaling):* respondents see a list of single items -- for example, a list of distinct symptoms or disease impacts -- and pick the best and worst *item* from each subset shown. This is the simplest case, structurally similar to a straightforward ranking exercise.
- *Case 2 (profile case):* respondents see a single multi-attribute profile (much like one alternative in a DCE) and identify the best and worst *attribute-level* within that one profile -- for instance, within one treatment description, which single feature (efficacy level, side-effect level, dosing level) is most and least appealing.
- *Case 3 (multi-profile case):* respondents see multiple multi-attribute profiles side by side, much like a full DCE choice task, and identify the best and worst profile (or, in some designs, best and worst attribute-level across profiles) from the set. This case sits closest to a conventional DCE and is the most demanding cognitively.

#heor-practice[
  Case 1 object-scaling BWS is useful early in instrument development -- for example, prioritizing which symptoms or impacts matter most to patients before designing a full DCE around the most important ones. Case 2 and Case 3 designs are closer to preference-weighting exercises proper, and Case 3 in particular is often analysed with the same conditional/mixed logit machinery described for DCEs in the previous section, simply with a "worst" choice added to the model alongside the "best" choice.
]

Both DCEs and BWS sit under the broader umbrella term *conjoint analysis*: a family of preference-elicitation methods that decompose a respondent's overall preference for a multi-attribute option into attribute-level contributions, or "part-worths." The terminology here is worth being precise about, because the terms are often used loosely in applied literature. A DCE is frequently described as a form of *choice-based conjoint analysis* -- respondents choose between whole profiles, and attribute-level utilities are inferred indirectly from the pattern of choices via a logit model. This is distinct from older, traditional *ratings-based* (or "full-profile") conjoint analysis, where respondents directly rate or rank a series of complete profiles on a scale, and part-worths are estimated more directly from those ratings. Ratings-based conjoint predates choice-based conjoint historically but is considerably less common in current HTA and health-preference research, largely because choice tasks are thought to better mimic real decision-making than abstract rating judgements, and because the random-utility framework underlying choice-based methods provides a more defensible statistical link to actual decision behaviour.

These preference-elicitation methods are not purely academic exercises -- they increasingly feed directly into HTA and economic-modelling workflows. Patient preference data from DCEs and BWS studies is used to supplement clinical evidence in benefit-risk assessments, to inform value frameworks that weigh outcomes beyond the strict endpoints captured in a trial, and occasionally to parametrize utility weights or acceptable trade-offs within an economic model itself.

#agency-note[
  This is a real, active regulatory and methodological area, not a speculative aspiration. The FDA's Center for Devices and Radiological Health has published a standing guidance, *"Incorporating Voluntary Patient Preference Information over the Total Product Life Cycle"* (updated 2026, superseding the original 2016 version issued under Section 1137 of the Food and Drug Administration Safety and Innovation Act), setting out how voluntary Patient Preference Information can inform FDA's benefit-risk determinations across premarket review pathways -- including a published "List of Patient Preference-Sensitive Priority Areas" identifying clinical categories where this evidence is considered especially valuable. On the methods side, ISPOR's Good Research Practices for Conjoint Analysis Task Force published a consensus 10-item checklist for conjoint-analysis studies in health (Bridges et al., *Value in Health*, 2011) covering research question framing, attribute/level selection, experimental design, and statistical analysis -- the closest thing this sub-field has to a CHEERS-style reporting standard, and a reasonable first reference when designing or critiquing a DCE or BWS study intended to support an HTA submission.
]


#pitfall[
  DCE and BWS results describe *stated* preferences -- what a respondent says they would choose in a hypothetical, carefully structured scenario on paper or screen. This is not the same as *revealed* preferences -- what people actually do when faced with the real decision, with real consequences, real financial constraints, real time pressure, and real clinical context surrounding them. Stated-preference studies are enormously useful precisely because they can probe trade-offs (like a specific side-effect risk versus a specific efficacy gain) that rarely occur in exactly that form in real-world data, letting researchers isolate attribute weights that would be nearly impossible to estimate from observational data alone. But that same hypothetical framing is also their central limitation: respondents may answer differently on paper than they would in the exam room, under the pressure of an actual diagnosis, with their own money or their own body's symptoms on the line. Any application of DCE/BWS findings to real-world policy or pricing decisions should treat the resulting weights as a well-grounded approximation of underlying preferences, not an exact prediction of real-world choice behaviour, and triangulate against observational or revealed-preference evidence where it exists.
]

With this, Part VII's survey of HTA-in-practice methods -- survival modelling, network meta-analysis, and now patient-reported outcomes and preference research -- comes to a close. Chapter 34 turns to the methodological frontier: machine learning, large language models, digital twins, and the broader future of how HEOR analyses are likely to be built in R in the years ahead.
