package M0;

import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class r implements Parcelable {
    public static final Parcelable.Creator<r> CREATOR = new W(13);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Enum f1033a;

    /* JADX WARN: Multi-variable type inference failed */
    public r(InterfaceC0065a interfaceC0065a) {
        this.f1033a = (Enum) interfaceC0065a;
    }

    public static r a(int i4) throws C0081q {
        InterfaceC0065a interfaceC0065a;
        if (i4 == -262) {
            interfaceC0065a = G.RS1;
        } else {
            G[] gArrValues = G.values();
            int length = gArrValues.length;
            int i5 = 0;
            while (true) {
                if (i5 >= length) {
                    for (EnumC0082s enumC0082s : EnumC0082s.values()) {
                        if (enumC0082s.f1035a == i4) {
                            interfaceC0065a = enumC0082s;
                        }
                    }
                    throw new C0081q(B1.a.l("Algorithm with COSE value ", i4, " not supported"));
                }
                G g4 = gArrValues[i5];
                if (g4.f964a == i4) {
                    interfaceC0065a = g4;
                    break;
                }
                i5++;
            }
        }
        return new r(interfaceC0065a);
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    /* JADX WARN: Type inference failed for: r0v1, types: [M0.a, java.lang.Enum] */
    /* JADX WARN: Type inference failed for: r2v3, types: [M0.a, java.lang.Enum] */
    public final boolean equals(Object obj) {
        return (obj instanceof r) && this.f1033a.a() == ((r) obj).f1033a.a();
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1033a});
    }

    /* JADX WARN: Type inference failed for: r2v1, types: [M0.a, java.lang.Enum] */
    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeInt(this.f1033a.a());
    }
}
