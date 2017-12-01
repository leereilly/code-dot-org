const SET_REGIONAL_PARTNER_NAME = 'application_dashboard/SET_REGIONAL_PARTNER_NAME';
const SET_LOCK_APPLICATION_PERMISSION = 'application_dashboard/SET_LOCK_APPLICATION_PERMISSION';

const initialState = {
  regionalPartnerName: "All Regional Partner Applications",
  permissions: {}
};

export default function reducer(state = initialState, action) {
  switch (action.type) {
    case SET_REGIONAL_PARTNER_NAME:
      return {
        ...state,
        regionalPartnerName: action.name
      };

    case SET_LOCK_APPLICATION_PERMISSION:
      return {
        ...state,
        permissions: {
          ...state.permissions,
          lockApplication: action.enabled
        }
      };

    default:
      return state;
  }
}

export const setRegionalPartnerName = (name) => ({
  type: SET_REGIONAL_PARTNER_NAME,
  name
});

export const setLockApplicationPermission = (enabled) => ({
  type: SET_LOCK_APPLICATION_PERMISSION,
  enabled
});
