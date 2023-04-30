// Copyright (C) 2023 Slack Technologies, LLC
// SPDX-License-Identifier: Apache-2.0
package com.slack.circuit.sample.counter

import app.cash.molecule.RecompositionClock
import app.cash.molecule.launchMolecule
import app.cash.molecule.moleculeFlow
import com.rickclephas.kmm.viewmodel.KMMViewModel
import com.rickclephas.kmm.viewmodel.stateIn
import com.slack.circuit.runtime.CircuitUiState
import com.slack.circuit.runtime.Navigator
import com.slack.circuit.runtime.presenter.Presenter
import com.slack.circuit.runtime.presenter.presenterOf
import com.slack.circuit.sample.counter.util.IO
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.launch

fun newCounterPresenter() = KMMPresenter(presenterOf { CounterPresenter(Navigator.NoOp) })

//fun <UiState : CircuitUiState> Presenter<UiState>.asSwiftPresenter(): SwiftPresenter<UiState> {
//  return SwiftPresenter(this)
//}

// Adapted from the KotlinConf app
// https://github.com/JetBrains/kotlinconf-app/blob/642404f3454d384be966c34d6b254b195e8d2892/shared/src/commonMain/kotlin/org/jetbrains/kotlinconf/utils/Coroutines.kt#L6
// No interface because interfaces don't support generics in Kotlin/Native.
// TODO let's try to generify this pattern somehow.
//class SwiftPresenter<UiState : CircuitUiState>
//internal constructor(
//  private val delegate: Presenter<UiState>,
//) {
//  // TODO ew globalscope
//  @OptIn(DelicateCoroutinesApi::class)
//  fun subscribe(block: (UiState) -> Unit): Job {
//    return GlobalScope.launch(Dispatchers.IO) {
//      launchMolecule(RecompositionClock.Immediate) { delegate.present() }.collect { block(it) }
//    }
//  }
//}

class KMMPresenter<UiState: CircuitUiState>(
  private val presenter: Presenter<UiState>
): KMMViewModel() {

  private val stateFlow = moleculeFlow(RecompositionClock.Immediate) {
    presenter.present()
  }.stateIn(viewModelScope, Dispatchers.IO, SharingStarted.WhileSubscribed(), null) // TODO: hmm initial null state

  val state: UiState? get() = stateFlow.value
}
