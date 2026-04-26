package l1;

import android.os.Build;
import android.os.StrictMode;
import com.google.firebase.concurrent.ExecutorsRegistrar;
import java.util.Collections;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import m1.ScheduledExecutorServiceC0552g;
import m1.ThreadFactoryC0546a;
import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class e implements InterfaceC0634a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5595a;

    @Override // q1.InterfaceC0634a
    public final Object get() {
        switch (this.f5595a) {
            case 0:
                return Collections.EMPTY_SET;
            case 1:
                return null;
            case 2:
                n nVar = ExecutorsRegistrar.f3865a;
                StrictMode.ThreadPolicy.Builder builderDetectNetwork = new StrictMode.ThreadPolicy.Builder().detectNetwork();
                int i4 = Build.VERSION.SDK_INT;
                builderDetectNetwork.detectResourceMismatches();
                if (i4 >= 26) {
                    builderDetectNetwork.detectUnbufferedIo();
                }
                return new ScheduledExecutorServiceC0552g(Executors.newFixedThreadPool(4, new ThreadFactoryC0546a("Firebase Background", 10, builderDetectNetwork.penaltyLog().build())), (ScheduledExecutorService) ExecutorsRegistrar.f3868d.get());
            case 3:
                n nVar2 = ExecutorsRegistrar.f3865a;
                return new ScheduledExecutorServiceC0552g(Executors.newFixedThreadPool(Math.max(2, Runtime.getRuntime().availableProcessors()), new ThreadFactoryC0546a("Firebase Lite", 0, new StrictMode.ThreadPolicy.Builder().detectAll().penaltyLog().build())), (ScheduledExecutorService) ExecutorsRegistrar.f3868d.get());
            case 4:
                n nVar3 = ExecutorsRegistrar.f3865a;
                return new ScheduledExecutorServiceC0552g(Executors.newCachedThreadPool(new ThreadFactoryC0546a("Firebase Blocking", 11, null)), (ScheduledExecutorService) ExecutorsRegistrar.f3868d.get());
            default:
                n nVar4 = ExecutorsRegistrar.f3865a;
                return Executors.newSingleThreadScheduledExecutor(new ThreadFactoryC0546a("Firebase Scheduler", 0, null));
        }
    }
}
