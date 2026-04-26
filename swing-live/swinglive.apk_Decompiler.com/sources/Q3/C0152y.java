package Q3;

import android.util.Log;
import java.util.Arrays;
import u3.AbstractC0692a;
import y3.InterfaceC0765f;

/* JADX INFO: renamed from: Q3.y, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0152y implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1671a;

    public /* synthetic */ C0152y(int i4) {
        this.f1671a = i4;
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        switch (this.f1671a) {
            case 0:
                InterfaceC0765f interfaceC0765f = (InterfaceC0765f) obj;
                if (interfaceC0765f instanceof A) {
                    return (A) interfaceC0765f;
                }
                return null;
            case 1:
                return w3.i.f6729a;
            case 2:
                Z3.a aVar = (Z3.a) obj;
                J3.i.e(aVar, "$this$sendHandshakeRecord");
                Z3.a aVar2 = new Z3.a();
                int iA = (int) AbstractC0692a.a(aVar2);
                aVar.n((byte) ((iA >>> 16) & 255));
                aVar.o((short) (iA & 65535));
                AbstractC0692a.d(aVar, aVar2);
                return w3.i.f6729a;
            case 3:
                J3.i.e((Z3.a) obj, "<this>");
                return w3.i.f6729a;
            case 4:
                Byte b5 = (Byte) obj;
                b5.byteValue();
                return String.format("%02x", Arrays.copyOf(new Object[]{b5}, 1));
            default:
                String str = (String) obj;
                J3.i.e(str, "reason");
                Log.e("StreamPreviewView", "Connection failed: ".concat(str));
                return w3.i.f6729a;
        }
    }
}
