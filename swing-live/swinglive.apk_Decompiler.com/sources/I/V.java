package I;

import androidx.lifecycle.InterfaceC0218d;
import java.io.File;
import java.math.BigInteger;
import java.util.LinkedHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class V extends J3.j implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f615a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f616b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ V(Object obj, int i4) {
        super(0);
        this.f615a = i4;
        this.f616b = obj;
    }

    @Override // I3.a
    public final Object a() {
        String strSubstring;
        switch (this.f615a) {
            case 0:
                Object obj = W.f618d;
                File file = (File) this.f616b;
                synchronized (obj) {
                    W.f617c.remove(file.getAbsolutePath());
                }
                return w3.i.f6729a;
            case 1:
                File file2 = (File) ((K.b) this.f616b).a();
                String name = file2.getName();
                J3.i.d(name, "getName(...)");
                int iLastIndexOf = name.lastIndexOf(46, P3.m.s0(name));
                if (iLastIndexOf == -1) {
                    strSubstring = "";
                } else {
                    strSubstring = name.substring(iLastIndexOf + 1, name.length());
                    J3.i.d(strSubstring, "substring(...)");
                }
                if (strSubstring.equals("preferences_pb")) {
                    File absoluteFile = file2.getAbsoluteFile();
                    J3.i.d(absoluteFile, "file.absoluteFile");
                    return absoluteFile;
                }
                throw new IllegalStateException(("File extension for file: " + file2 + " does not match required extension for Preferences file: preferences_pb").toString());
            case 2:
                androidx.lifecycle.I i4 = (androidx.lifecycle.I) this.f616b;
                androidx.lifecycle.H hG = i4.g();
                Q.b bVarA = i4 instanceof InterfaceC0218d ? ((InterfaceC0218d) i4).a() : Q.a.f1508b;
                J3.i.e(hG, "store");
                J3.i.e(bVarA, "defaultCreationExtras");
                LinkedHashMap linkedHashMap = hG.f3062a;
                Object e = (androidx.lifecycle.F) linkedHashMap.get("androidx.lifecycle.internal.SavedStateHandlesVM");
                if (androidx.lifecycle.E.class.isInstance(e)) {
                    J3.i.c(e, "null cannot be cast to non-null type T of androidx.lifecycle.ViewModelProvider.get");
                } else {
                    ((LinkedHashMap) new Q.c(bVarA).f1509a).put(androidx.lifecycle.G.f3061b, "androidx.lifecycle.internal.SavedStateHandlesVM");
                    try {
                        e = new androidx.lifecycle.E();
                        androidx.lifecycle.F f4 = (androidx.lifecycle.F) linkedHashMap.put("androidx.lifecycle.internal.SavedStateHandlesVM", e);
                        if (f4 != null) {
                            f4.a();
                        }
                    } catch (AbstractMethodError unused) {
                        throw new UnsupportedOperationException("Factory.create(String) is unsupported.  This Factory requires `CreationExtras` to be passed into `create` method.");
                    }
                }
                return (androidx.lifecycle.E) e;
            default:
                f0.h hVar = (f0.h) this.f616b;
                return BigInteger.valueOf(hVar.f4280a).shiftLeft(32).or(BigInteger.valueOf(hVar.f4281b)).shiftLeft(32).or(BigInteger.valueOf(hVar.f4282c));
        }
    }
}
