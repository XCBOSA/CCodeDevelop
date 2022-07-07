//
//  IntentHandler.swift
//  RunCScriptCommandHandler
//
//  Created by 邢铖 on 2022/7/6.
//  Copyright © 2022 xcbosa. All rights reserved.
//

import UIKit
import Intents

class IntentHandler: INExtension, RunCScriptIntentHandling {

    override func handler(for intent: INIntent) -> Any { self }

    func handle(intent: RunCScriptIntent, completion: @escaping (RunCScriptIntentResponse) -> Void) {
        let runner = RunnerDriver()
        let files = [
            CodeFile(fileName: "CDEnvC-Run-Script.c", content: intent.source ?? "")
        ]
        let env = CodeEnvironment(files: files, startIndex: 0)
        
        DispatchQueue.global(qos: .userInitiated).async {
            runner.runCode(inEnvironment: env)
            completion(.success(output: runner.stdout))
        }
        
        
        
        

//            while runner.processThread != nil {
//                usleep(20000)
//            }
        
    }

    func resolveSource(for intent: RunCScriptIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        completion(.success(with: intent.source ?? ""))
    }

}
