---
title       : An expert system for RGF operation
subtitle    : WQTC 2015
author      : Andrew Upton
job         : Cranfield University
framework   : revealjs
highlighter : shower  # {highlight.js, prettify, highlight}
hitheme     : solarized_light      # 
revealjs    :
          theme: sky
          center: "true"
widgets     : [dygraphs angularjs rCharts: libraries/nvd3]            # {mathjax, quiz, bootstrap}
mode        : standalone  # {draft  , selfcontained}
knit        : slidify::knit2slides
---




## An expert system for RGF operation

AWWA WQTC Conference 2015

Andrew Upton

Dr Peter Jarvis

Professor Bruce Jefferson

<img src="IMAGES/cranfield.png" style="background:none; border:none; box-shadow:none;">
<img src="IMAGES/EPSRC.png" style="background:none; border:none; box-shadow:none;">
<img src="IMAGES/scotwat.jpg" style="background:none; border:none; box-shadow:none;">

---

## Overview

- Definitions
- Key messages
- Introduction
- Rationale
- Example of prototype system
- Further work

---

## A few definitions
- <span style="color:blue">Expert system:</span> A software system which combines a knowledge base and a reasoning mechanism to solve a problem in a specific domain
- <span style="color:blue">Machine learning:</span> The application of generalisable algorithms which can develop data driven models to assist prediction or decision making
- <span style="color:blue">Hybrid system:</span> A system which uses more than one branch of artificial intelligence to perform a function

---

## Key messages

- Many <span style="font-weight:bold">SCADA</span> systems are <span style="color:green; font-weight:bold">good at collecting data </span> but <span style="color:red; font-weight:bold"> bad at helping us understand it.</span>
- Effective use of <span style="font-weight:bold">process data can inform decisions and reduce risk.</span>
- Process investigations can be focused on key areas, reducing cost and disruption.
- Combining expert process knowledge and machine learning methods can provide <span style="color:green; font-weight:bold">valuable insights for treatment operation, maintenance and enhancement</span>.

--- 

## Filtration

<div style='text-align: center;'>
    <img height='560' src='IMAGES/FILTER.jpg' />
</div>

---

## Challenges

<iframe src="fltmg_diag.html" width=850 height=500 allowtransparency="true" scrolling="no"> </iframe>

---

## Turbidity

- Filtration performance is typically monitored in terms of turbidity because it is <span style="color:orange; font-weight:bold">robust</span> and <span style="color:orange; font-weight:bold">cheap</span>
- Turbidity measurement is <span style="color:orange; font-weight:bold">subject to interferences</span> particularly at the levels of interest.
- The relationships between turbidity, particles, micro-organisms and pathogen risk are weak and inconsistent.
- Comparison of turbidity values at different times or from different systems is not the same as comparing risk.

---

## Filter performance

- We want to maintain <span style="color:orange; font-weight:bold">multiple barriers</span> to pathogens and particles.
- Filtrate turbidity <span style="color:green; font-weight:bold">less than 0.1 NTU </span> is considered to indicate that a barrier is likely to be effective and the that performance is acceptable or <span style="color:green; font-weight:bold">good</span>.
- Filtrate turbidity <span style="color:red; font-weight:bold"> greater than 0.1 NTU </span> is considered to indicate that a barrier is likely to be less effective and that performance should be improved or is <span style="color:red; font-weight:bold">poor</span>.
- It is more useful and informative to understand the occurence and context of good and poor perfomance than to compare turbidity values obtainted under different conditions and at different times.

---

## Previous work

- Expert systems for alarm management (Dandy & Simpson 1991)
- Improved tools for monitoring control signals (Liukkonen et al 2013)
- Filter maintenance and operation guidance manual (Logsdon et al, 2002)
- Partnership for safe water filtration turbidity performance scheme
- Application of SQC for cryptosporidium control (Hall et al 2001)
- Many applications of machine-learning for coagulant dose optimization

---

## Aims for system

Develop an interactive software tool combining process data and expert knowledge to facilitate:

- rapid assessment, comparison and communication of filter performance over the medium term
- identify the most likely dominant causes of poor filtration performance over the medium term

---

## Tools

<center><img src="IMAGES/R.png" alt="R" style="width: 250px;"/> <img src="IMAGES/RSTUDIO.jpg" alt="RStudio" style="width: 200px;"/><center>

https://www.r-project.org/

https://www.rstudio.com/

---

## Case study:

<iframe src="sys_diag.html" width=850 height=200 allowtransparency="true" scrolling="no"> </iframe>





































