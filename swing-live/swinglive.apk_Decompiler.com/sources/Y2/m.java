package y2;

import com.swing.live.MainActivity;
import java.io.IOException;
import x3.s;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class m implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6925a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Y0.n f6926b;

    public /* synthetic */ m(Y0.n nVar, int i4) {
        this.f6925a = i4;
        this.f6926b = nVar;
    }

    @Override // I3.a
    public final Object a() {
        switch (this.f6925a) {
            case 0:
                final Y0.n nVar = this.f6926b;
                final int i4 = 0;
                ((MainActivity) nVar.f2488a).runOnUiThread(new Runnable() { // from class: y2.n
                    @Override // java.lang.Runnable
                    public final void run() throws IOException {
                        switch (i4) {
                            case 0:
                                O2.g gVar = (O2.g) nVar.f2491d;
                                if (gVar != null) {
                                    gVar.a(s.d0(new w3.c("event", "connected"), new w3.c("bitrate", 0L), new w3.c("fps", 0), new w3.c("droppedFrames", 0), new w3.c("isConnected", Boolean.TRUE), new w3.c("elapsedSeconds", 0L)));
                                }
                                break;
                            default:
                                O2.g gVar2 = (O2.g) nVar.f2491d;
                                if (gVar2 != null) {
                                    gVar2.a(s.d0(new w3.c("event", "disconnected"), new w3.c("bitrate", 0L), new w3.c("fps", 0), new w3.c("droppedFrames", 0), new w3.c("isConnected", Boolean.FALSE), new w3.c("elapsedSeconds", 0L)));
                                }
                                break;
                        }
                    }
                });
                break;
            default:
                final Y0.n nVar2 = this.f6926b;
                final int i5 = 1;
                ((MainActivity) nVar2.f2488a).runOnUiThread(new Runnable() { // from class: y2.n
                    @Override // java.lang.Runnable
                    public final void run() throws IOException {
                        switch (i5) {
                            case 0:
                                O2.g gVar = (O2.g) nVar2.f2491d;
                                if (gVar != null) {
                                    gVar.a(s.d0(new w3.c("event", "connected"), new w3.c("bitrate", 0L), new w3.c("fps", 0), new w3.c("droppedFrames", 0), new w3.c("isConnected", Boolean.TRUE), new w3.c("elapsedSeconds", 0L)));
                                }
                                break;
                            default:
                                O2.g gVar2 = (O2.g) nVar2.f2491d;
                                if (gVar2 != null) {
                                    gVar2.a(s.d0(new w3.c("event", "disconnected"), new w3.c("bitrate", 0L), new w3.c("fps", 0), new w3.c("droppedFrames", 0), new w3.c("isConnected", Boolean.FALSE), new w3.c("elapsedSeconds", 0L)));
                                }
                                break;
                        }
                    }
                });
                break;
        }
        return w3.i.f6729a;
    }
}
