package m1;

import android.os.Handler;
import android.os.Looper;
import java.util.concurrent.Executor;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class k implements Executor {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final k f5790a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Handler f5791b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ k[] f5792c;

    static {
        k kVar = new k("INSTANCE", 0);
        f5790a = kVar;
        f5792c = new k[]{kVar};
        f5791b = new Handler(Looper.getMainLooper());
    }

    public static k valueOf(String str) {
        return (k) Enum.valueOf(k.class, str);
    }

    public static k[] values() {
        return (k[]) f5792c.clone();
    }

    @Override // java.util.concurrent.Executor
    public final void execute(Runnable runnable) {
        f5791b.post(runnable);
    }
}
