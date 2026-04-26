package P0;

import K.k;
import android.os.Parcel;
import com.google.android.gms.common.api.internal.O;
import com.google.android.gms.common.api.internal.Z;
import com.google.android.gms.internal.base.zab;
import com.google.android.gms.internal.base.zac;

/* JADX INFO: loaded from: classes.dex */
public abstract class c extends zab {
    @Override // com.google.android.gms.internal.base.zab
    public final boolean zaa(int i4, Parcel parcel, Parcel parcel2, int i5) {
        switch (i4) {
            case 3:
                break;
            case 4:
                break;
            case 5:
            default:
                return false;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                break;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                break;
            case k.BYTES_FIELD_NUMBER /* 8 */:
                g gVar = (g) zac.zaa(parcel, g.CREATOR);
                O o4 = (O) this;
                o4.f3428b.post(new Z(2, o4, gVar));
                break;
            case 9:
                break;
        }
        parcel2.writeNoException();
        return true;
    }
}
