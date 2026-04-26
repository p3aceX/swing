package r2;

import android.os.Process;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class j implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6361a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ r f6362b;

    public /* synthetic */ j(r rVar, int i4) {
        this.f6361a = i4;
        this.f6362b = rVar;
    }

    @Override // I3.a
    public final Object a() {
        switch (this.f6361a) {
            case 0:
                y2.g gVar = (y2.g) this.f6362b.f6388a.f5788a;
                gVar.f6893k.set(false);
                gVar.f6897o.set(0L);
                gVar.f6888f.a();
                break;
            case 1:
                this.f6362b.f6388a.a("No response from server");
                break;
            case 2:
                this.f6362b.f6388a.a("Shutdown received from server");
                break;
            case 3:
                this.f6362b.f6388a.getClass();
                Process.setThreadPriority(-19);
                break;
            case 4:
                this.f6362b.f6388a.a("Endpoint malformed, should be: srt://ip:port/streamid");
                break;
            case 5:
                this.f6362b.f6388a.a("Endpoint malformed, should be: srt://ip:port/streamid");
                break;
            default:
                y2.g gVar2 = (y2.g) this.f6362b.f6388a.f5788a;
                gVar2.f6893k.set(true);
                gVar2.e.a();
                break;
        }
        return w3.i.f6729a;
    }

    public /* synthetic */ j(r rVar, String str) {
        this.f6361a = 3;
        this.f6362b = rVar;
    }
}
