package y2;

import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class i implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6911a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ k f6912b;

    public /* synthetic */ i(k kVar, int i4) {
        this.f6911a = i4;
        this.f6912b = kVar;
    }

    @Override // I3.a
    public final Object a() {
        switch (this.f6911a) {
            case 0:
                Log.d("StreamPreviewView", "Connection success");
                m mVar = this.f6912b.f6919g;
                if (mVar != null) {
                    mVar.a();
                }
                break;
            default:
                Log.d("StreamPreviewView", "Disconnected");
                m mVar2 = this.f6912b.f6920h;
                if (mVar2 != null) {
                    mVar2.a();
                }
                break;
        }
        return w3.i.f6729a;
    }
}
