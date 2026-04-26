package e2;

import android.os.Process;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class z implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4231a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ L f4232b;

    public /* synthetic */ z(L l2, int i4) {
        this.f4231a = i4;
        this.f4232b = l2;
    }

    @Override // I3.a
    public final Object a() {
        switch (this.f4231a) {
            case 0:
                y2.g gVar = (y2.g) this.f4232b.f4048a.f5788a;
                gVar.f6893k.set(false);
                gVar.f6897o.set(0L);
                gVar.f6888f.a();
                break;
            case 1:
                this.f4232b.f4048a.getClass();
                break;
            case 2:
                y2.g gVar2 = (y2.g) this.f4232b.f4048a.f5788a;
                gVar2.f6897o.set(0L);
                gVar2.f6887d.invoke("Authentication error");
                break;
            case 3:
                y2.g gVar3 = (y2.g) this.f4232b.f4048a.f5788a;
                gVar3.f6897o.set(0L);
                gVar3.f6887d.invoke("Authentication error");
                break;
            case 4:
                y2.g gVar4 = (y2.g) this.f4232b.f4048a.f5788a;
                gVar4.f6893k.set(true);
                gVar4.e.a();
                break;
            case 5:
                this.f4232b.f4048a.a("No response from server");
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                this.f4232b.f4048a.getClass();
                Process.setThreadPriority(-19);
                break;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                this.f4232b.f4048a.a("Endpoint malformed, should be: rtmp://ip:port/appname/streamname");
                break;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                this.f4232b.f4048a.a("Endpoint malformed, should be: rtmp://ip:port/appname/streamname");
                break;
            default:
                this.f4232b.f4048a.a("Handshake failed");
                break;
        }
        return w3.i.f6729a;
    }

    public /* synthetic */ z(L l2, String str) {
        this.f4231a = 6;
        this.f4232b = l2;
    }
}
