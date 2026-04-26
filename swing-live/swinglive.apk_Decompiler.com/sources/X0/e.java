package x0;

import K.k;
import android.accounts.Account;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.SignInAccount;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import java.util.ArrayList;
import y0.C0737a;

/* JADX INFO: loaded from: classes.dex */
public final class e implements Parcelable.Creator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6762a;

    public /* synthetic */ e(int i4) {
        this.f6762a = i4;
    }

    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        switch (this.f6762a) {
            case 0:
                int iI0 = H0.a.i0(parcel);
                int iU = 0;
                String strQ = null;
                String strQ2 = null;
                String strQ3 = null;
                String strQ4 = null;
                Uri uri = null;
                String strQ5 = null;
                String strQ6 = null;
                ArrayList arrayListU = null;
                String strQ7 = null;
                String strQ8 = null;
                long jW = 0;
                while (parcel.dataPosition() < iI0) {
                    int i4 = parcel.readInt();
                    switch ((char) i4) {
                        case 1:
                            iU = H0.a.U(i4, parcel);
                            break;
                        case 2:
                            strQ = H0.a.q(i4, parcel);
                            break;
                        case 3:
                            strQ2 = H0.a.q(i4, parcel);
                            break;
                        case 4:
                            strQ3 = H0.a.q(i4, parcel);
                            break;
                        case 5:
                            strQ4 = H0.a.q(i4, parcel);
                            break;
                        case k.STRING_SET_FIELD_NUMBER /* 6 */:
                            uri = (Uri) H0.a.o(parcel, i4, Uri.CREATOR);
                            break;
                        case k.DOUBLE_FIELD_NUMBER /* 7 */:
                            strQ5 = H0.a.q(i4, parcel);
                            break;
                        case k.BYTES_FIELD_NUMBER /* 8 */:
                            jW = H0.a.W(i4, parcel);
                            break;
                        case '\t':
                            strQ6 = H0.a.q(i4, parcel);
                            break;
                        case '\n':
                            arrayListU = H0.a.u(parcel, i4, Scope.CREATOR);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            strQ7 = H0.a.q(i4, parcel);
                            break;
                        case '\f':
                            strQ8 = H0.a.q(i4, parcel);
                            break;
                        default:
                            H0.a.e0(i4, parcel);
                            break;
                    }
                }
                H0.a.y(iI0, parcel);
                return new GoogleSignInAccount(iU, strQ, strQ2, strQ3, strQ4, uri, strQ5, jW, strQ6, arrayListU, strQ7, strQ8);
            case 1:
                int iI02 = H0.a.i0(parcel);
                ArrayList arrayListU2 = null;
                int iU2 = 0;
                boolean zS = false;
                boolean zS2 = false;
                boolean zS3 = false;
                ArrayList arrayListU3 = null;
                Account account = null;
                String strQ9 = null;
                String strQ10 = null;
                String strQ11 = null;
                while (parcel.dataPosition() < iI02) {
                    int i5 = parcel.readInt();
                    switch ((char) i5) {
                        case 1:
                            iU2 = H0.a.U(i5, parcel);
                            break;
                        case 2:
                            arrayListU3 = H0.a.u(parcel, i5, Scope.CREATOR);
                            break;
                        case 3:
                            account = (Account) H0.a.o(parcel, i5, Account.CREATOR);
                            break;
                        case 4:
                            zS = H0.a.S(i5, parcel);
                            break;
                        case 5:
                            zS2 = H0.a.S(i5, parcel);
                            break;
                        case k.STRING_SET_FIELD_NUMBER /* 6 */:
                            zS3 = H0.a.S(i5, parcel);
                            break;
                        case k.DOUBLE_FIELD_NUMBER /* 7 */:
                            strQ9 = H0.a.q(i5, parcel);
                            break;
                        case k.BYTES_FIELD_NUMBER /* 8 */:
                            strQ10 = H0.a.q(i5, parcel);
                            break;
                        case '\t':
                            arrayListU2 = H0.a.u(parcel, i5, C0737a.CREATOR);
                            break;
                        case '\n':
                            strQ11 = H0.a.q(i5, parcel);
                            break;
                        default:
                            H0.a.e0(i5, parcel);
                            break;
                    }
                }
                H0.a.y(iI02, parcel);
                return new GoogleSignInOptions(iU2, arrayListU3, account, zS, zS2, zS3, strQ9, strQ10, GoogleSignInOptions.d(arrayListU2), strQ11);
            default:
                int iI03 = H0.a.i0(parcel);
                String strQ12 = "";
                GoogleSignInAccount googleSignInAccount = null;
                String strQ13 = "";
                while (parcel.dataPosition() < iI03) {
                    int i6 = parcel.readInt();
                    char c5 = (char) i6;
                    if (c5 == 4) {
                        strQ12 = H0.a.q(i6, parcel);
                    } else if (c5 == 7) {
                        googleSignInAccount = (GoogleSignInAccount) H0.a.o(parcel, i6, GoogleSignInAccount.CREATOR);
                    } else if (c5 != '\b') {
                        H0.a.e0(i6, parcel);
                    } else {
                        strQ13 = H0.a.q(i6, parcel);
                    }
                }
                H0.a.y(iI03, parcel);
                return new SignInAccount(strQ12, googleSignInAccount, strQ13);
        }
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ Object[] newArray(int i4) {
        switch (this.f6762a) {
            case 0:
                return new GoogleSignInAccount[i4];
            case 1:
                return new GoogleSignInOptions[i4];
            default:
                return new SignInAccount[i4];
        }
    }
}
