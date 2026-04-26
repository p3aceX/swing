package d4;

import X.N;
import java.util.concurrent.ConcurrentHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3959a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final b4.a f3960b;

    public c(int i4) {
        this.f3959a = i4;
        switch (i4) {
            case 1:
                this.f3960b = new f();
                new ConcurrentHashMap();
                new ThreadLocal();
                new a();
                break;
            default:
                this.f3960b = new N(5);
                new ConcurrentHashMap();
                break;
        }
    }
}
