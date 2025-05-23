import SwiftUI
import SwiftData

// MARK: - Protocols
@MainActor
protocol ContainerProtocol {
    var modelContext: ModelContext { get }
    var shiftRepository: ShiftRepository { get }
    var companyRepository: CompanyRepository { get }
    var holidayRepository: HolidayRepository { get }
    var shiftUseCase: ShiftUseCaseProtocol { get }
    var companyUseCase: CompanyUseCaseProtocol { get }
    var holidayUseCase: HolidayUseCaseProtocol { get }
    var salaryUseCase: SalaryUseCaseProtocol { get }
    var payDayUseCase: PayDayUseCaseProtocol { get }
}

// MARK: - Container
@MainActor
final class DependencyContainer: ContainerProtocol {
    
    private let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    var modelContext: ModelContext {
        modelContainer.mainContext
    }
    
    var shiftRepository: ShiftRepository {
        SwiftDataShiftRepo(context: modelContext)
    }
    
    var companyRepository: CompanyRepository {
        SwiftDataCompanyRepo(context: modelContext)
    }
    
    var holidayRepository: HolidayRepository {
        SwiftDataHolidayRepository(context: modelContext, apiClient: HolidayAPIClient())
    }
    
    var shiftUseCase: ShiftUseCaseProtocol {
        ShiftUseCase(shiftRepository: shiftRepository)
    }
    
    var companyUseCase: CompanyUseCaseProtocol {
        CompanyUseCase(companyRepository: companyRepository)
    }
    
    var holidayUseCase: HolidayUseCaseProtocol {
        HolidayUseCase(holidayRepository: holidayRepository)
    }
    
    var salaryUseCase: SalaryUseCaseProtocol {
        SalaryUseCase(holidayUseCase: holidayUseCase)
    }
    
    var payDayUseCase: PayDayUseCaseProtocol {
        PayDayUseCase(holidayUseCase: holidayUseCase, salaryUseCase: salaryUseCase, shiftUseCase: shiftUseCase)
    }
}

// MARK: - Environment Key
private struct ContainerKey: @preconcurrency EnvironmentKey {
    @MainActor
    static let defaultValue: ContainerProtocol = DependencyContainer(
        modelContainer: try! ModelContainer(for: Schema([Company.self, Shift.self, Holiday.self]))
    )
}

// MARK: - Environment Values
extension EnvironmentValues {
    var container: ContainerProtocol {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}

// MARK: - View Extension
extension View {
    func injectDependencies(_ container: ContainerProtocol) -> some View {
        environment(\.container, container)
    }
} 
